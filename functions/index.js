/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//     logger.info("Hello logs!", {structuredData: true});
//     response.send("Hello from Firebase!");
// });

// 최대 추출할 일기 ID 수를 정의하는 상수
const MAX_DIARY_COUNT = 5;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
require("dotenv").config();
const {OpenAI} = require("openai");
const moment = require("moment-timezone"); // moment-timezone을 사용해야 합니다.
const timeZone = "Asia/Seoul"; // 한국 시간대 설정

admin.initializeApp();
const db = admin.firestore();

// OpenAI API Configuration
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

// 매월 마지막 날 실행되는 PubSub 트리거 설정
exports.monthlyDiaryReview = functions.region("asia-northeast3").pubsub.schedule("0 0 28-31 * *")
    // 매 2분마다 실행하는 테스트 조건
    // exports.testDiaryReview = functions.region("asia-northeast3").pubsub.schedule("*/2 * * * *")
    .timeZone("Asia/Seoul")
    .onRun(async (context) => {
        // 현재 UTC 시간을 가져오고, 이를 서울 시간대로 변환
        const today = moment.tz(timeZone); // moment 객체를 한국 시간대로 생성
        const currentMonth = today.format("YYYY-MM"); // "YYYY-MM" 형식으로 현재 월 가져오기
        const lastDayOfMonth = today.clone().endOf("month"); // 달의 마지막 날을 가져오기

        // 오늘과 마지막 날을 읽기 쉬운 형식으로 변환
        const todayFormatted = today.format("YYYY-MM-DD HH:mm:ssZ");
        const lastDayFormatted = lastDayOfMonth.format("YYYY-MM-DD HH:mm:ssZ");

        // 오늘이 달의 마지막 날인지 확인
        if (today.date() !== lastDayOfMonth.date()) {
            console.log(`[Exit] Today (${todayFormatted}) is not the last day of month. Last day of month was (${lastDayFormatted}).`);
            return null;
        } else {
            console.log(`[Proceed] Today (${todayFormatted}) is the last day of the month.`);
        }

        const usersRef = db.collection("users");
        const usersSnapshot = await usersRef.get();

        const tasks = usersSnapshot.docs.map(async (userDoc) => {
            const userData = userDoc.data();
            const myDiaryId = userData.myDiaryId || [];

            // 일기 ID 배열의 뒤에서부터 MAX_DIARY_COUNT개의 ID를 추출
            const lastFiveDiaryIds = myDiaryId.slice(-MAX_DIARY_COUNT);

            // 다이어리 데이터를 가져오고 날짜 검증
            const validEntries = await Promise.all(lastFiveDiaryIds.map(async (diaryId) => {
                const diaryDoc = await db.collection("allDiary").doc(diaryId).get();
                if (diaryDoc.exists) {
                    const diaryData = diaryDoc.data();
                    const createdAt = diaryData.createdAt.toDate(); // Firestore Timestamp to JS Date
                    const diaryMonth = createdAt.toISOString().slice(0, 7); // "YYYY-MM"

                    // 현재 달에 작성된 일기만 필터링
                    if (diaryMonth === currentMonth) {
                        return {
                            content: diaryData.content,
                            emotion: diaryData.emotion,
                        };
                    }
                }
                return null;
            }));

            // 유효한 엔트리 필터링
            const filteredEntries = validEntries.filter((entry) => entry !== null);

            if (filteredEntries.length < 5) {
                console.log(`[Skipping] User ${userDoc.id} does not have enough valid diary entries for the current month.`);
                return;
            } else {
                console.log(`[Proceed] User ${userDoc.id} has enough valid diary entries for the current month.`);
            }

            // 다이어리 텍스트 구성
            const diaryText = filteredEntries.map((entry) => {
                return `Diary: ${entry.content}\nEmotions: ${entry.emotion.join(", ")}`;
            }).join("\n\n");


            // TODO: 추후 모델 학습 or 프롬프트 개선 필요
            const systemMessage = {
                content:
                    `You are a kind assistant. Write an encouraging letter in Korean, addressing the user by their name (${userDoc.nickname} or '친구'), based on their diary entries and emotions. Conclude the letter without a signature or sender's name.`,
                role: "system",
            };

            const userDiarySet = {
                content:
                    `Here are some recent diary entries with their emotions:\n${diaryText}`,

                role: "user",
            };

            const requestMessages = [
                systemMessage,
                userDiarySet,
            ];

            try {
                const lettersRef = db.collection("users").doc(userDoc.id).collection("letters");

                const existingLetterSnapshot = await lettersRef.where("title", "==", `${today.toDate().getFullYear()}년 ${today.toDate().getMonth() + 1}월 편지`).get();

                if (!existingLetterSnapshot.empty) {
                    console.log(`[Skipping] User ${userDoc.id} already has a letter for this month.`);
                    return;
                } else {
                    console.log(`[Proceed] User ${userDoc.id} does not have a letter for this month.`);
                }

                const response = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: requestMessages,
                    n: 1,
                    max_tokens: 512,
                    frequency_penalty: 0,
                    presence_penalty: 0,
                    temperature: 1.0,
                    top_p: 1.0,
                });

                const letterContent = response.choices[0].message.content.trim();

                await db.runTransaction(async (transaction) => {
                    const letterId = lettersRef.doc().id;
                    const letterTitle = `${today.toDate().getFullYear()}년 ${today.toDate().getMonth() + 1}월 편지`;

                    transaction.set(lettersRef.doc(letterId), {
                        content: letterContent,
                        date: admin.firestore.FieldValue.serverTimestamp(),
                        letterId: letterId,
                        title: letterTitle,
                    });

                    // 새로운 편지 플래그 설정 (편지 생성됨 변수)
                    transaction.update(db.collection("users").doc(userDoc.id), {
                        newLetterAvailable: true,
                    });

                    const notificationTitle = `${letterTitle}가 도착했어요`;
                    const notificationType = "letter";

                    // 알림 추가 함수 호출
                    await addNotification(userDoc.id, notificationTitle, notificationType, letterId);

                    // 유저에게 FCM 토큰으로 알림 전송
                    const fcmToken = userData.fcmToken;
                    if (fcmToken) {
                        const message = {
                            notification: {
                                title: `${letterTitle}가 도착했어요!`,
                                body: "이번 달의 편지를 확인하세요.",
                            },
                            data: {
                                screen: "letter_detail",
                                letterId: letterId,
                            },
                            token: fcmToken,
                        };

                        try {
                            await admin.messaging().send(message);
                            console.log(`[Success] Notification sent to user ${userDoc.id}`);
                        } catch (error) {
                            console.error(`[Error] Failed to send notification to user ${userDoc.id}: ${error.message}`);
                        }
                    } else {
                        console.log(`[Error] No FCM token found for user ${userDoc.id}, notification not sent.`);
                    }

                    // // 각 편지의 id를 담은 대표 문서 생성 로직
                    // // Reference to the summary document
                    // // 문서 이름을 콜렉션의 맨 앞에 항상 정렬 0000_~~~
                    // const summaryDocRef = lettersRef.doc('0000_docSummary');

                    // // Get the summary document
                    // const summaryDoc = await transaction.get(summaryDocRef);

                    // if (!summaryDoc.exists) {
                    //     // If the summary document does not exist, create it with the new letter ID
                    //     transaction.set(summaryDocRef, {
                    //         letterIds: [letterId]
                    //     });
                    // } else {
                    //     // If the summary document exists, update the letterIds array
                    //     transaction.update(summaryDocRef, {
                    //         letterIds: admin.firestore.FieldValue.arrayUnion(letterId)
                    //     });
                    // }
                });

                console.log(`[Success] Encouragement letter for user ${userDoc.id} created successfully.`);
            } catch (error) {
                if (error instanceof OpenAI.APIError) {
                    console.error(`[Error] Failed to create encouragement letter for user ${userDoc.id}:`, error.message);
                } else {
                    // Non-API error
                    console.log(error);
                }
            }
        });

        try {
            await Promise.all(tasks);
            console.log(`[Exit] All tasks have been completed successfully.`);
        } catch (error) {
            console.error(`[Error] An error occurred while executing tasks:`, error);
        }

        console.log(`[Exit] Function execution completed.`);

        return null;
    });

// 공감 일기의 알림 전송 함수
exports.sendLikedDiaryNotification = functions.https.onCall(async (data, context) => {
    const {likedDiaryId, fcmToken, userId} = data;

    // 알림 메시지 정의
    const message = {
        notification: {
            title: `누군가 나의 기록에 공감했어요!`,
            body: "나의 기록을 확인해보세요.",
        },
        data: {
            screen: "liked_diary_detail",
            likedDiaryId: likedDiaryId,
        },
        token: fcmToken,
    };

    try {
        await admin.messaging().send(message);
        console.log(`[Success] Notification sent to user ${userId}`);
    } catch (error) {
        console.error(`[Error] Failed to send notification to user ${userId}: ${error.message}`);
    }

    const notificationTitle = "누군가 나의 기록에 공감했어요";
    const notificationType = "likedDiary";

    // 알림 추가 함수 호출
    await addNotification(userId, notificationTitle, notificationType, likedDiaryId);
});

/**
 * 사용자에게 새로운 알림을 추가하는 함수
 * @param {string} userId - 알림을 받을 사용자의 ID
 * @param {string} notificationTitle - 알림의 제목
 * @param {string} notificationType - 알림의 타입
 * @param {string} notificationDataId - 알림과 관련된 일기 id
 * @return {Promise<void[]>}
 */
async function addNotification(userId, notificationTitle, notificationType, notificationDataId) {
    try {
        console.log(`[Proceed] Adding notification for user ${userId}`);

        const notificationsRef = db.collection("users").doc(userId).collection("notifications");

        await db.runTransaction(async (transaction) => {
            // 알림 ID 생성
            const notificationId = notificationsRef.doc().id;
            // 알림 요약 문서 레퍼런스
            const summaryDocRef = notificationsRef.doc("0000_docSummary");

            // Summary document 읽기
            const summaryDoc = await transaction.get(summaryDocRef);

            // 알림 생성 (쓰기 작업은 읽기 작업 후에 실행)
            console.log(`[Proceed] Creating notification for user ${userId}, notificationId: ${notificationId}`);
            transaction.set(notificationsRef.doc(notificationId), {
                notificationId: notificationId,
                type: notificationType,
                title: notificationTitle,
                dataId: notificationDataId,
                date: admin.firestore.FieldValue.serverTimestamp(),
            });

            // 새로운 알림이 있다는 플래그 설정
            console.log(`[Proceed] Setting newNotificationsAvailable flag for user ${userId}`);
            transaction.update(db.collection("users").doc(userId), {
                newNotificationsAvailable: true,
            });

            // summary 문서 처리
            if (!summaryDoc.exists) {
                console.log(`[Proceed] Summary document does not exist for user ${userId}, creating new summary document`);
                // summary 문서가 없으면 생성
                transaction.set(summaryDocRef, {
                    isNew: 1,
                });
            } else {
                console.log(`[Proceed] Summary document exists for user ${userId}, updating isNew field`);
                // summary 문서가 있으면 업데이트
                transaction.update(summaryDocRef, {
                    isNew: admin.firestore.FieldValue.increment(1),
                });
            }
        });

        console.log(`[Success] Notification added for user ${userId}`);
    } catch (error) {
        console.error(`[Error] Failed to add notification for user ${userId}: ${error.message}`);
    }
}

// 유저 정보의 모든 관련 콜렉션을 삭제하는 함수
// TODO: 추후 계정 탈퇴 관련 함수 수정 요청하기
exports.deleteUserDataAndDoc = functions.https.onCall(async (data, context) => {
    const userId = data.userId;
    const userRef = admin.firestore().collection("users").doc(userId);

    /**
     * Deletes all documents in a specified sub-collection.
     *
     * @param {string} subCollectionName - The name of the sub-collection to delete.
     * @return {Promise<void[]>} A promise that resolves when all documents in the sub-collection are deleted.
     */
    async function deleteSubCollection(subCollectionName) {
        const subCollection = await userRef.collection(subCollectionName).get();
        const deletePromises = subCollection.docs.map((doc) => doc.ref.delete());
        return Promise.all(deletePromises);
    }

    try {
        // Delete sub-collections first
        await deleteSubCollection("letters");
        await deleteSubCollection("otherDiary");

        // Then delete the user document itself
        await userRef.delete();

        console.log(`User document and sub-collections for ${userId} deleted.`);
        return {success: true};
    } catch (error) {
        console.error(`Error deleting user data: ${userId}`, error);
        return {success: false, error: error.message};
    }
});

// Firebase Authentication 계정 삭제 함수
// TODO: 추후 계정 탈퇴 관련 함수 수정 요청하기
exports.deleteAuthUser = functions.https.onCall(async (data, context) => {
    const userId = data.userId;

    try {
        await admin.auth().deleteUser(userId);
        console.log(`Successfully deleted user: ${userId}`);
        return {success: true};
    } catch (error) {
        console.error(`Error deleting user: ${userId}`, error);
        return {success: false, error: error.message};
    }
});
