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

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { OpenAI } = require("openai");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });

admin.initializeApp();
const db = admin.firestore();

// OpenAI API Configuration
const configuration = new OpenAI({
    apiKey: process.env["OPENAI_API_KEY"],
});

// OpenAI API Configuration
// const configuration = new Configuration({
//     apiKey: process.env.OPENAI_API_KEY,
// });

const openai = new OpenAI(configuration);

// 매월 마지막 날 실행되는 PubSub 트리거 설정
// exports.monthlyDiaryReview = functions.region("asia-northeast3").pubsub.schedule('0 0 28-31 * *')
exports.testDiaryReview = functions.region("asia-northeast3").pubsub.schedule("*/2 * * * *") // 매 2분마다 실행하는 테스트 조건
    .timeZone("Asia/Seoul")
    .onRun(async (context) => {
        const today = new Date();
        const currentMonth = today.toISOString().slice(0, 7); // "YYYY-MM"
        const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

        // 달의 마지막 날인지 확인
        if (today.getDate() !== lastDayOfMonth.getDate()) {
            console.log("오늘은 달의 마지막 날이 아닙니다. 함수 종료.");
            return null;
        }

        const usersRef = db.collection("users");
        const usersSnapshot = await usersRef.get();

        const tasks = usersSnapshot.docs.map(async (userDoc) => {
            const userData = userDoc.data();
            const myDiaryId = userData.myDiaryId || [];

            // 뒤에서부터 5개의 일기 ID 추출
            const lastFiveDiaryIds = myDiaryId.slice(-5);

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
                console.log(`User ${userDoc.id} does not have enough valid diary entries for the current month. Skipping.`);
                return;
            }

            // 다이어리 텍스트 구성
            const diaryText = filteredEntries.map((entry) => {
                return `Diary: ${entry.content}\nEmotions: ${entry.emotion.join(", ")}`;
            }).join("\n\n");

            const prompt = `Here are some recent diary entries with their emotions:\n\n${diaryText}\n\nPlease write an encouraging and empathetic letter based on these entries in Korean.`;

            try {
                const response = await openai.createCompletion({
                    model: "gpt-4o-mini",
                    prompt: prompt,
                    n: 1,
                    maxTokens: 512,
                    frequencyPenalty: 0,
                    presencePenalty: 0,
                    temperature: 1.0,
                    topP: 1.0,
                });

                const letterContent = response.data.choices[0].text.trim();
                const lettersRef = db.collection("users").doc(userDoc.id).collection("letters");

                await db.runTransaction(async (transaction) => {
                    const existingLetterSnapshot = await transaction.get(
                        lettersRef.where("title", "==", `${today.getFullYear()}년 ${today.getMonth() + 1}월의 편지`),
                    );

                    if (!existingLetterSnapshot.empty) {
                        console.log(`User ${userDoc.id} already has a letter for this month. Skipping.`);
                        return;
                    }

                    const letterId = lettersRef.doc().id;

                    transaction.set(lettersRef.doc(letterId), {
                        content: letterContent,
                        date: admin.firestore.FieldValue.serverTimestamp(),
                        letterId: letterId,
                        title: `${today.getFullYear()}년 ${today.getMonth() + 1}월의 편지`,
                    });
                });

                console.log(`Encouragement letter for user ${userDoc.id} created successfully.`);
            } catch (error) {
                console.error(`Failed to create encouragement letter for user ${userDoc.id}:`, error);
            }
        });

        await Promise.all(tasks);

        return null;
    });
