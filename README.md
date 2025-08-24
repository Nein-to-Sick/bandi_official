# 반디 (Bandi) - AI 기반 감정 일기 플랫폼

[![PlayStore](https://img.shields.io/badge/PlayStore-Download-green)](https://play.google.com/store/apps/details?id=com.bandi.official)
[![AppStore](https://img.shields.io/badge/AppStore-Download-blue)](https://apps.apple.com/kr/app/%EB%B0%98%EB%94%94-ai-%EA%B0%90%EC%A0%95-%EC%9D%BC%EC%A7%80/id6717578973)

---

## 🌟 프로젝트 소개
**반디(Bandi)** 는 AI 기반 감정 분석과 회고 기능을 제공하는 **일상 감정 관리 플랫폼**입니다.  
Flutter와 Firebase를 기반으로 개발되었으며, 실제 **구글 플레이스토어와 애플 앱스토어에 출시**되어 운영 중입니다.

- 감정 일기 작성 및 자동 감정 키워드 분석  
- ChatGPT 기반 맞춤형 회고 챗봇  
- Firebase Cloud Messaging 기반 푸시 알림  
- DeepL API를 통한 번역 및 다국어 지원  

---

## 🛠️ 기술 스택
- **Frontend**
  - Flutter (Dart), Provider (상태관리)
  - Responsive UI (모바일/태블릿 대응)
- **Backend & Infra**
  - Firebase Firestore (NoSQL DB)
  - Firebase Cloud Functions (Serverless API)
  - Firebase Cloud Messaging (푸시 알림)
  - Firebase Authentication (Google, Apple OAuth)
- **AI & 번역**
  - OpenAI ChatGPT API (감정 분석, 회고 챗봇)
  - DeepL API (다국어 번역 지원)
- **배포**
  - Google PlayStore / Apple AppStore
  - CI/CD 배포 경험

---

## 🖼️ 앱 스크린샷

| 홈 화면 | 감정 일기 작성 | 감정 분석 결과 |
|:---:|:---:|:---:|
| ![홈](assets/screenshots/home.png) | ![일기](assets/screenshots/diary.png) | ![분석](assets/screenshots/analysis.png) |

| 챗봇 회고 | 알림 기능 | 다국어 지원 |
|:---:|:---:|:---:|
| ![챗봇](assets/screenshots/chatbot.png) | ![알림](assets/screenshots/notification.png) | ![번역](assets/screenshots/multilang.png) |

---

## 🏗️ 시스템 아키텍처

```mermaid
flowchart TD

subgraph Client[모바일 앱 (Flutter)]
  UI[UI/UX 화면]
  State[Provider 상태관리]
end

subgraph Firebase[Firebase & GCP]
  Auth[Authentication (Google/Apple OAuth)]
  DB[(Firestore Database)]
  Functions[Cloud Functions]
  FCM[Cloud Messaging]
end

subgraph External[외부 API]
  OpenAI[ChatGPT API]
  DeepL[DeepL API]
end

User((사용자)) -->|일기 작성| UI
UI --> State
State --> DB
UI -->|로그인| Auth
DB --> Functions
Functions -->|알림 Trigger| FCM
Functions -->|AI 호출| OpenAI
Functions -->|번역| DeepL
FCM --> UI

## 🔥 기술적 도전 과제 & 해결 방법

1. 알림(FCM) & 라우팅 문제
문제: 앱 종료 상태에서 알림 클릭 시 특정 화면 이동 실패 (Context 불안정)

해결: 알림 데이터를 큐에 저장 → 앱 초기화 완료 후 안전하게 라우팅 처리

2. iOS 배지 카운트 초기화
문제: 앱 진입 시 알림 배지 카운트가 초기화되지 않아 iOS 심사 리젝 발생

해결: UNUserNotificationCenter와 FirebaseMessaging을 함께 활용해 앱 진입 시 배지 초기화

3. Firestore 데이터 최적화
문제: 다이어리-좋아요 관계에서 중첩 구조로 인해 쿼리 비용 과다

해결: 단일 참조 구조 설계 및 Cloud Functions 후처리 적용 → 쿼리 단순화 및 비용 절감

4. AI 비용 최적화
문제: ChatGPT API 호출 시 토큰 과다 사용 → 응답 지연 및 비용 증가

해결: 감정 키워드 추출 프롬프트 최소화 + Firebase Functions 캐싱 → 응답 속도 개선 & 비용 절감

## 📂 코드 스니펫 (Cloud Functions)

// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 좋아요 발생 시 작성자에게 알림 전송
exports.sendLikedDiaryNotification = functions.firestore
  .document("likes/{likeId}")
  .onCreate(async (snapshot, context) => {
    const likeData = snapshot.data();
    const { diaryId, senderId, receiverId } = likeData;

    // 수신자 FCM 토큰 조회
    const userDoc = await admin.firestore().collection("users").doc(receiverId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return null;

    // 다이어리 정보 조회
    const diaryDoc = await admin.firestore().collection("diaries").doc(diaryId).get();
    const diary = diaryDoc.data();

    // 알림 메시지 생성
    const message = {
      token: fcmToken,
      notification: {
        title: "새로운 반응이 도착했어요!",
        body: `${senderId}님이 "${diary.title}"에 공감했어요.`,
      },
      data: { type: "like", diaryId },
    };

    // 알림 발송
    await admin.messaging().send(message);
  });

## 📊 프로젝트 성과

✅ iOS AppStore & Android PlayStore 동시 출시

✅ 예비창업패키지 선정 프로젝트 (경북창조경제혁신센터)

🏆 SW 창업경진대회 대상 수상

🏆 포스텍 미니 아이코어 프로그램 우수상 수상

## 👥 역할

김형진

Flutter 프론트엔드 & Firebase 백엔드 개발

Cloud Functions 및 서버리스 아키텍처 구현

ChatGPT API 연동 및 최적화

배포 및 스토어 심사 대응

김경록


권세한


## 📌 배운 점

Firebase Functions, FCM 등 실무 수준 난이도 있는 문제 해결 경험

iOS/Android 플랫폼별 차이를 고려한 운영 능력 확보

실제 사용자 피드백 기반 지속적인 개선 사이클 운영

## ✨ 한 줄 소개

“실서비스를 개발·출시·운영하며, 복잡한 기술적 문제를 해결할 수 있는 풀스택 모바일 개발자”
