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
const { OpenAI } = require("openai");

admin.initializeApp();
const db = admin.firestore();

// OpenAI API Configuration
const openai = new OpenAI({
    apiKey: functions.config().openai.key,
});

// 매월 마지막 날 실행되는 PubSub 트리거 설정
// exports.monthlyDiaryReview = functions.region("asia-northeast3").pubsub.schedule('0 0 28-31 * *')
exports.testDiaryReview = functions.region("asia-northeast3").pubsub.schedule("*/2 * * * *") // 매 2분마다 실행하는 테스트 조건
    .timeZone("Asia/Seoul")
    .onRun(async (context) => {
        const today = new Date();
        const currentMonth = today.toISOString().slice(0, 7); // "YYYY-MM"
        const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

        // 오늘이 달의 마지막 날인지 확인
        if (today.getDate() !== lastDayOfMonth.getDate()) {
            console.log("[Exit] Today is not the last day of month.");
            // return null;
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
                    "You are a helpful assistant. Please write an encouraging and empathetic letter in Korean based on the diary entries and the emotions expressed in them.",

                role: "system",
            };

            const userDiarySet = {
                content:
                    `Here are some recent diary entries with their emotions:\n\n${diaryText}`,

                role: "user",
            };

            const requestMessages = [
                systemMessage,
                userDiarySet,
            ];

            try {
                const lettersRef = db.collection("users").doc(userDoc.id).collection("letters");

                const existingLetterSnapshot = await lettersRef.where("title", "==", `${today.getFullYear()}년 ${today.getMonth() + 1}월의 편지`).get();

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

                    transaction.set(lettersRef.doc(letterId), {
                        content: letterContent,
                        date: admin.firestore.FieldValue.serverTimestamp(),
                        letterId: letterId,
                        title: `${today.getFullYear()}년 ${today.getMonth() + 1}월 편지`,
                    });
                });

                console.log(`[Success] Encouragement letter for user ${userDoc.id} created successfully.`);

                // // 유저에게 FCM 토큰으로 알림 전송
                // const fcmToken = userData.fcmToken;
                // if (fcmToken) {
                //     const message = {
                //         notification: {
                //             title: "새로운 편지가 도착했어요!",
                //             body: "이번 달의 편지를 확인하세요.",
                //         },
                //         token: fcmToken,
                //     };

                //     try {
                //         await admin.messaging().send(message);
                //         console.log(`[Success] Notification sent to user ${userDoc.id}`);
                //     } catch (error) {
                //         console.error(`[Error] Failed to send notification to user ${userDoc.id}:`, error);
                //     }
                // } else {
                //     console.log(`[Info] No FCM token found for user ${userDoc.id}, notification not sent.`);
                // }
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
