const functions = require("firebase-functions");
const admin = require("firebase-admin");
require("dotenv").config();
const { OpenAI } = require("openai");
const moment = require("moment-timezone");

// 이미 초기화된 경우를 대비한 조건부 초기화
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
const MAX_DIARY_COUNT = 5;
const TIME_ZONE = "Asia/Seoul";

/**
 * 헬퍼 함수: 배열을 지정된 크기(chunkSize)로 나누어 반환
 * 동시 실행 제어를 위해 사용
 * @param {Array} array - 나눌 원본 배열
 * @param {number} chunkSize - 한 묶음의 크기
 * @return {Array[]} 묶음으로 나누어진 2차원 배열
 */
function chunkArray(array, chunkSize) {
    const results = [];
    while (array.length) {
        results.push(array.splice(0, chunkSize));
    }
    return results;
}

/**
 * 헬퍼 함수: 개별 사용자 처리를 담당 (Main 로직 분리)
 * @param {object} userDoc - Firestore 사용자 문서 스냅샷
 * @param {string} currentMonth - 처리할 기준 월 (YYYY-MM)
 * @param {object} today - 처리 기준 날짜의 Moment 객체
 * @return {Promise<object>} 처리 성공 여부와 결과 객체
 */
async function processUserLetter(userDoc, currentMonth, today) {
    const userId = userDoc.id;
    const userData = userDoc.data();
    const myDiaryId = userData.myDiaryId || [];

    // 1. 일기 데이터가 아예 없으면 조기 종료
    if (myDiaryId.length === 0) {
        return { status: "skipped", reason: "no_diary", userId };
    }

    try {
        // 이미 이번 달 편지가 있는지 확인 (불필요한 OpenAI 호출 방지)
        const lettersRef = db.collection("users").doc(userId).collection("letters");
        const letterTitle = `${today.toDate().getFullYear()}년 ${today.toDate().getMonth() + 1}월 편지`;

        // title 쿼리에 인덱스가 필요할 수 있음. 복합 쿼리 에러 발생 시 인덱스 생성 링크 클릭 필요.
        const existingLetterSnapshot = await lettersRef.where("title", "==", letterTitle).limit(1).get();

        if (!existingLetterSnapshot.empty) {
            console.log(`[Skipping] User ${userId} already has a letter for this month.`);
            return { status: "skipped", reason: "already_exists", userId };
        }

        // 2. 일기 가져오기 (최신순 5개)
        const lastFiveDiaryIds = myDiaryId.slice(-MAX_DIARY_COUNT);

        const validEntries = await Promise.all(lastFiveDiaryIds.map(async (diaryId) => {
            // 에러 핸들링 추가: 일기가 삭제되었을 경우 대비
            try {
                const diaryDoc = await db.collection("allDiary").doc(diaryId).get();
                if (!diaryDoc.exists) return null;

                const diaryData = diaryDoc.data();
                if (!diaryData.createdAt) return null;

                const createdAt = diaryData.createdAt.toDate();
                const diaryMonth = moment(createdAt).tz(TIME_ZONE).format("YYYY-MM");

                if (diaryMonth === currentMonth) {
                    return {
                        content: diaryData.content,
                        emotion: Array.isArray(diaryData.emotion) ? diaryData.emotion : [diaryData.emotion], // 배열 안전 처리
                        date: moment(createdAt).tz(TIME_ZONE).format("YYYY-MM-DD"),
                    };
                }
            } catch (e) {
                console.warn(`Error fetching diary ${diaryId} for user ${userId}:`, e);
                return null;
            }
            return null;
        }));

        const filteredEntries = validEntries.filter((entry) => entry !== null);

        // 최소 일기 개수 조건 체크
        if (filteredEntries.length < MAX_DIARY_COUNT) {
            console.log(`[Skipping] User ${userId} - Not enough entries (${filteredEntries.length}).`);
            return { status: "skipped", reason: "not_enough_entries", userId };
        }

        // 3. OpenAI 프롬프트 구성
        // 날짜 정보를 포함하여 더 구체적인 피드백 유도
        const diaryText = filteredEntries.map((entry) => {
            return `[${entry.date}] Content: ${entry.content} / Emotions: ${entry.emotion.join(", ")}`;
        }).join("\n");

        const langCode = userData.language || "ko";
        const nickname = userData.nickname || (langCode === "ko" ? "유저님" : "User");

        // [수정됨] 프롬프트 엔지니어링: 고정된 서명 문구 추가
        const systemPrompt = langCode === "ko" ?
            `당신은 사용자의 마음을 어루만져주는 따뜻한 심리 상담가 AI '반디'입니다. 
               사용자의 이번 달 일기 내용을 바탕으로, 친구에게 말하듯 따뜻하고 격려가 담긴 편지를 작성해주세요.
               
               [작성 지침]
               - 수신자 호칭: ${nickname}
               - 말투: 해요체 (부드럽고 정중하게, 예: "했어요", "바라요")
               - 내용: 일기의 구체적인 사건이나 감정을 언급하며 깊이 공감해주세요.
               - 마무리: 편지의 맨 마지막 줄은 반드시 줄을 바꾼 뒤 정확히 다음 문구로 끝내세요:
                 "따스한 마음을 담아, 반디가"` :
            `You are 'Bandi', a warm and empathetic AI counselor. 
               Write an encouraging letter based on the user's diary entries for this month.
               
               [Writing Guidelines]
               - Recipient Name: ${nickname}
               - Tone: Warm, supportive, and friendly.
               - Content: Specifically mention events or emotions from the diary to show empathy.
               - Closing: At the very end of the letter, on a new line, you must sign off exactly as follows:
                 "With warm hearts, Bandi"`;

        const openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY,
        });

        const response = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: `Here are my diary entries for this month:\n${diaryText}` },
            ],
            max_tokens: 800, // [개선] 편지 길이를 고려해 약간 늘림
            temperature: 0.8, // [개선] 감성적인 글쓰기를 위해 약간 높임
            frequency_penalty: 0.3, // [개선] 반복적인 표현 억제
        });

        const letterContent = response.choices[0].message.content.trim();

        // [준비] ID와 알림 제목을 트랜잭션 외부에서 미리 생성 (FCM 전송 및 트랜잭션 내부 공통 사용을 위함)
        const newLetterRef = lettersRef.doc();
        const letterId = newLetterRef.id;

        const notificationTitle = langCode === "ko" ?
            `${letterTitle}가 도착했어요!` :
            `Bandi's Letter is here!`;

        // 4. 결과 저장 및 알림 DB 저장 (Transaction - 원자성 보장)
        await db.runTransaction(async (transaction) => {
            // 편지 저장
            transaction.set(newLetterRef, {
                content: letterContent,
                date: admin.firestore.FieldValue.serverTimestamp(),
                letterId: letterId,
                title: letterTitle,
            });

            // 유저 상태 업데이트
            transaction.update(db.collection("users").doc(userId), {
                newLetterAvailable: true,
            });

            // [핵심 수정] 알림 저장 함수를 트랜잭션 안에서 호출
            // 마지막 인자로 transaction 객체를 넘겨주어, 위 작업들과 한 몸처럼 동작하게 함
            await addNotification(userId, notificationTitle, "letter", letterId, transaction);
        });

        // 5. FCM 푸시 알림 전송 (DB 트랜잭션 성공 후 실행 - 외부 서비스이므로 트랜잭션 제외)
        if (userData.fcmToken) {
            const message = {
                notification: {
                    title: notificationTitle,
                    body: langCode === "ko" ? "이번 달의 편지를 확인하세요." : "Take a look at this month's letter.",
                },
                data: { screen: "letter_detail", letterId: letterId },
                token: userData.fcmToken,
            };

            try {
                await admin.messaging().send(message);
            } catch (e) {
                // FCM 전송 실패는 로직 전체 실패로 간주하지 않음 (로그만 남김)
                console.error(`FCM Error for ${userId}:`, e.message);
            }
        }

        console.log(`[Success] Letter created for ${userId}`);
        return { status: "success", userId };
    } catch (error) {
        console.error(`[Error] Processing user ${userId}:`, error);
        return { status: "error", reason: error.message, userId };
    }
}

// 메인 Cloud Function
exports.monthlyDiaryReview = functions
    .region("asia-northeast3")
    .runWith({
        timeoutSeconds: 540, // [개선] 9분으로 타임아웃 연장 (OpenAI 대기 시간 고려)
        memory: "1GB", // [개선] 다수의 유저 데이터 처리 시 메모리 확보
    })
    .pubsub.schedule("0 0 1 * *") // [개선] 매월 1일 자정에 실행 (28~31일 로직보다 깔끔함)
    .timeZone(TIME_ZONE)
    .onRun(async (context) => {
        const today = moment().tz(TIME_ZONE);
        // "어제"를 기준으로 지난 달을 계산 (1일 자정에 실행되므로 어제는 지난달의 마지막 날)
        const lastMonthDate = today.clone().subtract(1, "day");
        const targetMonthStr = lastMonthDate.format("YYYY-MM");

        console.log(`[Start] Monthly Review for ${targetMonthStr}. Execution Date: ${today.format()}`);

        // 모든 유저 가져오기
        // *주의: 유저가 수만 명이면 stream()을 사용해야 하지만, 수천 명 수준까지는 get() 후 chunking으로 커버 가능
        const usersSnapshot = await db.collection("users").get();
        const allUserDocs = usersSnapshot.docs;

        console.log(`[Info] Found ${allUserDocs.length} users.`);

        // [핵심 개선] 배치 처리 (Chunking)
        // 5명씩 끊어서 실행 (OpenAI Rate Limit 및 Firestore Write Limit 고려)
        const CHUNK_SIZE = 5;
        const chunks = chunkArray([...allUserDocs], CHUNK_SIZE); // 원본 배열 복사 후 chunking

        let successCount = 0;
        let skipCount = 0;
        let errorCount = 0;

        for (const chunk of chunks) {
            // 한 묶음(5명)을 병렬로 처리
            const results = await Promise.all(chunk.map((userDoc) =>
                processUserLetter(userDoc, targetMonthStr, lastMonthDate),
            ));

            // 결과 집계
            results.forEach((r) => {
                if (r.status === "success") successCount++;
                else if (r.status === "skipped") skipCount++;
                else errorCount++;
            });

            // [개선] Rate Limit 방지를 위한 딜레이 (1초)
            // OpenAI Tier가 높다면 없어도 되지만, 안전장치로 추가
            await new Promise((resolve) => setTimeout(resolve, 1000));
        }

        console.log(`[Exit] Completed. Success: ${successCount}, Skipped: ${skipCount}, Errors: ${errorCount}`);
        return null;
    });

// 공감 일기의 알림 전송 함수
exports.sendLikedDiaryNotification = functions.region("asia-northeast3").https.onCall(async (data, context) => {
    // [보안 1] 인증 확인: 로그인한 사용자만 호출 가능
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "로그인이 필요한 서비스입니다.");
    }

    // data.fcmToken은 보안상 신뢰할 수 없으므로 제거하고, DB에서 직접 조회합니다.
    const { likedDiaryId, userId } = data; // userId는 알림을 받을 대상(일기 작성자)

    // [보안 2] 필수 데이터 검증
    if (!likedDiaryId || !userId) {
        throw new functions.https.HttpsError("invalid-argument", "필요한 정보(likedDiaryId, userId)가 누락되었습니다.");
    }

    try {
        // [성능/보안] 알림 받을 유저 정보를 DB에서 한 번만 조회 (언어 설정 + FCM 토큰)
        const userDocRef = db.collection("users").doc(userId);
        const userDoc = await userDocRef.get();

        if (!userDoc.exists) {
            console.log(`[Error] Target user ${userId} not found.`);
            return { success: false, reason: "user_not_found" };
        }

        const userData = userDoc.data();
        const langCode = userData.language || "ko";

        // [보안 3] 클라이언트가 준 토큰이 아니라, DB에 저장된 신뢰할 수 있는 토큰 사용
        const targetFcmToken = userData.fcmToken;

        let notificationTitle = "";
        let notificationBody = "";
        const notificationType = "likedDiary";

        if (langCode === "ko") {
            notificationTitle = `누군가 나의 기록에 공감했어요!`;
            notificationBody = `나의 기록을 확인해보세요.`;
        } else {
            notificationTitle = `Someone reacted to your journal.`;
            notificationBody = `Take a look at your journal.`;
        }

        // 1. FCM 푸시 알림 전송
        if (targetFcmToken) {
            const message = {
                notification: {
                    title: notificationTitle,
                    body: notificationBody,
                },
                data: {
                    screen: "liked_diary_detail",
                    likedDiaryId: likedDiaryId,
                },
                token: targetFcmToken, // DB에서 가져온 토큰 사용
            };

            try {
                await admin.messaging().send(message);
                console.log(`[Success] Notification sent to user ${userId}`);
            } catch (fcmError) {
                // 토큰이 만료되었거나 삭제된 경우 등 에러 처리
                console.error(`[Warning] Failed to send FCM to user ${userId}: ${fcmError.message}`);
                // FCM 전송 실패가 DB 저장을 막으면 안 되므로 에러를 throw 하지 않음
            }
        } else {
            console.log(`[Info] User ${userId} has no FCM token. Skipping push notification.`);
        }

        // 2. 알림 내역 DB 저장 (이전에 개선한 함수 호출)
        // 여기서는 단일 작업이므로 트랜잭션을 굳이 넘기지 않아도 됩니다(자동으로 내부 트랜잭션 생성)
        await addNotification(userId, notificationTitle, notificationType, likedDiaryId);

        return { success: true };
    } catch (error) {
        console.error(`[Error] sendLikedDiaryNotification failed:`, error);
        throw new functions.https.HttpsError("internal", "알림 전송 중 오류가 발생했습니다.");
    }
});

/**
 * 사용자에게 새로운 알림을 추가하는 함수
 * @param {string} userId - 알림을 받을 사용자의 ID
 * @param {string} notificationTitle - 알림의 제목
 * @param {string} notificationType - 알림의 타입
 * @param {string} notificationDataId - 알림과 관련된 일기 id
 * @param {object} [transaction] - (선택) 외부에서 전달받은 Firestore Transaction 객체. 존재할 경우 해당 트랜잭션에 포함됨.
 * @return {Promise<void>}
 */
async function addNotification(userId, notificationTitle, notificationType, notificationDataId, transaction = null) {
    try {
        console.log(`[Proceed] Adding notification for user ${userId} (Type: ${notificationType})`);

        const userRef = db.collection("users").doc(userId);
        const notificationsRef = userRef.collection("notifications");
        const summaryDocRef = notificationsRef.doc("0000_docSummary");

        // 트랜잭션 내부에서 실행될 핵심 로직 (읽기 -> 쓰기 순서 준수)
        const executeNotificationLogic = async (t) => {
            // [READ] Summary document 읽기 (쓰기 전에 먼저 읽어야 함)
            const summaryDoc = await t.get(summaryDocRef);

            // 알림 ID 생성
            const notificationId = notificationsRef.doc().id;

            // [WRITE] 1. 알림 문서 생성
            console.log(`[Proceed] Creating notification doc: ${notificationId}`);
            t.set(notificationsRef.doc(notificationId), {
                notificationId: notificationId,
                type: notificationType,
                title: notificationTitle,
                dataId: notificationDataId,
                date: admin.firestore.FieldValue.serverTimestamp(),
            });

            // [WRITE] 2. 유저 플래그 업데이트
            t.update(userRef, {
                newNotificationsAvailable: true,
            });

            // [WRITE] 3. Summary 문서 업데이트 또는 생성
            if (!summaryDoc.exists) {
                // console.log(`[Proceed] Creating new summary doc for ${userId}`);
                t.set(summaryDocRef, {
                    isNew: 1,
                });
            } else {
                // console.log(`[Proceed] Updating summary doc for ${userId}`);
                t.update(summaryDocRef, {
                    isNew: admin.firestore.FieldValue.increment(1),
                });
            }
        };

        // 분기 처리: 외부 트랜잭션이 있으면 그것을 사용하고, 없으면 새로 만듦
        if (transaction) {
            // [Case A] 부모 트랜잭션에 포함 (await 필수)
            await executeNotificationLogic(transaction);
        } else {
            // [Case B] 독립적인 트랜잭션 실행
            await db.runTransaction(async (newTransaction) => {
                await executeNotificationLogic(newTransaction);
            });
        }

        console.log(`[Success] Notification process completed for user ${userId}`);
    } catch (error) {
        console.error(`[Error] Failed to add notification for user ${userId}: ${error.message}`);
        // 상위 함수(monthlyDiaryReview)에서 에러를 인지할 수 있도록 throw (선택 사항)
        throw error;
    }
}

/**
 * 매일 정해진 시간에 알림을 보내는 Cloud Function (Topic 방식 개선)
 * - DB 조회/저장 없음 (비용 $0)
 * - Topic을 사용하여 수백만 명에게도 즉시 전송 가능
 */
exports.sendDailyReminder = functions
    .region("asia-northeast3")
    .runWith({
        timeoutSeconds: 60, // 로직이 단순해져서 60초면 충분함
        memory: "256MB",    // 메모리도 최소 사양이면 됨
    })
    .pubsub.schedule("0 21 * * *") // 매일 오후 9시 (한국 시간)
    .timeZone("Asia/Seoul")
    .onRun(async (context) => {
        console.log("[Proceed] Daily Reminder Task Started (Topic Mode)");

        try {
            // 1. 한국어 사용자 전체 발송
            const messageKo = {
                notification: {
                    title: "오늘 하루는 어떠셨나요?",
                    body: "오늘의 기록을 남겨보세요 ✍️",
                },
                data: { screen: "diary_entry" },
                topic: "daily_reminder_ko", // 한국어 구독자 토픽
            };

            // 2. 영어 사용자 전체 발송
            const messageEn = {
                notification: {
                    title: "How was your day?",
                    body: "Write down your thoughts for today ✍️",
                },
                data: { screen: "diary_entry" },
                topic: "daily_reminder_en", // 영어 구독자 토픽
            };

            // 두 메시지를 병렬로 전송 (총 2번의 API 호출만 발생)
            await Promise.all([
                admin.messaging().send(messageKo),
                admin.messaging().send(messageEn),
            ]);

            console.log("[Success] Daily Reminder sent to topics (ko/en).");
        } catch (error) {
            console.error("[Error] Failed to send daily reminder:", error);
        }

        return null;
    });

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
        return { success: true };
    } catch (error) {
        console.error(`Error deleting user data: ${userId}`, error);
        return { success: false, error: error.message };
    }
});

// Firebase Authentication 계정 삭제 함수
// TODO: 추후 계정 탈퇴 관련 함수 수정 요청하기
exports.deleteAuthUser = functions.https.onCall(async (data, context) => {
    const userId = data.userId;

    try {
        await admin.auth().deleteUser(userId);
        console.log(`Successfully deleted user: ${userId}`);
        return { success: true };
    } catch (error) {
        console.error(`Error deleting user: ${userId}`, error);
        return { success: false, error: error.message };
    }
});
