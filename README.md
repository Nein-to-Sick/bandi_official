<img width="1920" height="686" alt="image" src="https://github.com/user-attachments/assets/5e6923ee-a23b-4a81-8cb3-9fc7a8267725" />

[![PlayStore](https://img.shields.io/badge/PlayStore-Download-green)](https://play.google.com/store/apps/details?id=com.bandi.official)
[![AppStore](https://img.shields.io/badge/AppStore-Download-blue)](https://apps.apple.com/kr/app/%EB%B0%98%EB%94%94-ai-%EA%B0%90%EC%A0%95-%EC%9D%BC%EC%A7%80/id6717578973)

## 📑 목차

1. [🌟 프로젝트 소개](#프로젝트-소개)  
2. [📊 프로젝트 성과](#프로젝트-성과)  
3. [🛠️ 기술 스택](#기술-스택)  
4. [🖼️ 앱 스크린샷](#앱-스크린샷)  
5. [🏗️ 시스템 아키텍처](#시스템-아키텍처)  
6. [🚀 기술적 도전 과제 & 해결 방법](#기술적-도전-과제--해결-방법)  
7. [💻 코드 스니펫 (Cloud Functions)](#코드-스니펫-cloud-functions)  
8. [👤 역할](#역할)  
9. [📚 배운 점](#배운-점)  
10. [✨ 한 줄 소개](#한-줄-소개)  

---

## 🌟 프로젝트 소개

**반디(Bandi)** 는 AI 기반 감정 분석과 회고 기능을 제공하는 **일상 감정 관리 플랫폼**입니다.  
<!-- Flutter와 Firebase를 기반으로 개발되었으며, 실제 **구글 플레이스토어와 애플 앱스토어에 출시**되어 운영 중입니다. (이건 없어도 될듯 밑에 있어서)--> 

- 감정 일기 작성 및 자동 감정 키워드 분석  
- ChatGPT 기반 맞춤형 회고 챗봇  
- Firebase Cloud Messaging 기반 푸시 알림  
- DeepL API를 통한 번역 및 다국어 지원  

---

## 📊 프로젝트 성과

✅ iOS AppStore & Android PlayStore 동시 출시  

| **🏆 K-Startup 예비창업패키지 지원 선정** | **🏆 제 13 회 창업경진대회 RPM 대상** |
|:---:|:---:|
| <img width="225" height="382" alt="image" src="https://github.com/user-attachments/assets/8538ab94-4612-4fc8-935b-438ca61fdaa7" /> | <img width="225" height="381" alt="image" src="https://github.com/user-attachments/assets/1eac3d4c-171d-48d7-b670-76a48cdadc6d" /> |
| 2024-04-29 | 2024-12-24 |
| [관련 기사 1](https://www.christian-journal.com/news/articleView.html?idxno=1096)   [관련 기사 2](http://www.mediagb.kr/news/view.php?idx=34988) | [관련 기사 1](https://www.christiandaily.co.kr/news/130618)   [관련 기사 2](https://www.christiandaily.co.kr/news/141242) |

- 🏆 **캡스톤디자인 경진대회 우수상** (2024-06-03)  
- 🏆 **POSTECH Mini-I-Corps 우수상** (2024-02-08)  
- 🏆 **제 12 회 창업경진대회 RPM 장려상** (2023-11-30)  
- 🏆 **SW Festival 문제해결 아이디어 공모전 장려상** (2023-11-17)  
- 🏆 **SW 창업 경진대회 대상** (2023-10-27)  

---

## 🛠️ 기술 스택

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-20232A?logo=flutter&logoColor=61DAFB)
![Responsive UI](https://img.shields.io/badge/Responsive%20UI-FF9800?logo=responsive&logoColor=white)

### Backend & DB
![Firebase Firestore](https://img.shields.io/badge/Firebase%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Cloud Functions](https://img.shields.io/badge/Firebase%20Functions-039BE5?logo=firebase&logoColor=white)
![Cloud Messaging](https://img.shields.io/badge/Firebase%20Messaging-FF6F00?logo=firebase&logoColor=white)
![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-DD2C00?logo=firebase&logoColor=white)

### AI & 번역
![OpenAI](https://img.shields.io/badge/OpenAI-412991?logo=openai&logoColor=white)
![DeepL](https://img.shields.io/badge/DeepL-0A4D8C?logo=deepl&logoColor=white)
![Flutter Localization](https://img.shields.io/badge/Flutter%20Localization-02569B?logo=flutter&logoColor=white)

### 배포
![Google Play](https://img.shields.io/badge/Google%20Play-414141?logo=googleplay&logoColor=white)
![App Store](https://img.shields.io/badge/App%20Store-0D96F6?logo=appstore&logoColor=white)
<!--![CI/CD](https://img.shields.io/badge/CI%2FCD-2088FF?logo=githubactions&logoColor=white) -->


---

## 🖼️ 앱 스크린샷

| 홈 화면 | 감정 일기 작성 | 감정 분석 결과 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/b5905b67-bae9-4a02-8ce6-fa549daa2978" alt="홈" width="202" height="438" /> | <img src="https://github.com/user-attachments/assets/076a1fd5-e872-46e2-860e-1b20c2457d8e" alt="일기" width="202" height="438" /> | <img src="https://github.com/user-attachments/assets/028cb29c-b555-42d9-becf-e9cda9e4b451" alt="분석" width="202" height="438" /> |

| 챗봇 회고 | 알림 기능 | 다국어 지원 |
|:---:|:---:|:---:|
| ![챗봇](assets/screenshots/chatbot.png) | ![알림](assets/screenshots/notification.png) | ![번역](assets/screenshots/multilang.png) |

---

## 🏗️ 시스템 아키텍처

```mermaid
flowchart TD

User((사용자)) -->|소셜 로그인| Auth[Google/Apple OAuth] --> Provider["상태관리\nProvider"] --> DB[(Firestore Database)]
User -->|일기 작성| Write[일기 작성]
Write --> Local[로컬 저장소]
Write --> DB

User -->|기록 공유| Share[공유된 기록]
Share -->|공감| Functions[Firebase Cloud Functions] -->|공감 / 알림 Trigger| FCM[Firebase Cloud Messaging] -->|알림| App[상대방앱]
Share -->|번역| DeepL[DeepL API]

Functions -->|AI 호출| OpenAI[ChatGPT API]
```

---

## 🔥 기술적 도전 과제 & 해결 방법

1. **다국어화 및 번역 토글 구현**
   - PR: [#133 Feature 다국어화(localization) 설정하기](https://github.com/Nein-to-Sick/bandi_official/pull/133)  
   - 내용: Flutter UI 전반과 Firebase Function에 다국어(Localization) 적용, 사용자 입력 일기 공유 시 DeepL API 기반 번역 토글 기능 구현  
   - 의미: 글로벌 사용자 대상 확장 및 플랫폼 내 언어 선택 유연성 강화  

2. **기록 공유의 신고 및 차단 기능 추가**
   - PR: [#144 Release 공유 알고리즘 개선 등](https://github.com/Nein-to-Sick/bandi_official/pull/144)  
   - 내용: 공유된 일기에서 부적절한 콘텐츠에 대한 신고 및 차단 기능 도입, 커뮤니티 안전성 확보  
   - 의미: 사용자 경험 중심의 책임 있는 서비스 운영  

3. **소셜 로그인 자동 무한 루프 오류 해결**
   - PR: [#136 Release 로그인 오류 수정](https://github.com/Nein-to-Sick/bandi_official/pull/136)  
   - 내용: 자동 로그인 시 발생하던 무한 재시도 루프 버그 수정, 안정적인 로그인 흐름 확보  
   - 의미: 원활한 사용자 흐름 보장 및 UX 개선  

4. **계정 탈퇴 기능 안정화 및 코드 개선**
   - PR: [#141 Fix 계정 탈퇴 버그 및 코드 개선](https://github.com/Nein-to-Sick/bandi_official/pull/141)  
   - 내용: 계정 탈퇴 시 무한 로딩 문제 수정, Firebase DB 및 Auth 계정 삭제 로직 정상화, 재인증 기능 보완  
   - 의미: 사용자 신뢰 확보 및 데이터 정합성 유지  

5. **인터넷 미연결 시 에러 핸들링 추가**
   - PR: [#123 Bug 인터넷 연결 시 에러 핸들링](https://github.com/Nein-to-Sick/bandi_official/pull/123)  
   - 내용: 로그인 전 네트워크 연결 여부 확인 및 적절한 에러 메시지 처리 로직 추가  
   - 의미: 네트워크 불안정 상황에서도 앱의 안정성 및 사용자 안내 강화  

---

## 📂 코드 스니펫 (Cloud Functions)

```js
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
```

---

## 👥 역할

| 이름 | 역할 |
|------|------|
| <pre>김형진</pre> | Flutter 프론트엔드 & Firebase 백엔드 개발, Cloud Functions 및 서버리스 아키텍처 구현, ChatGPT API 연동 및 최적화, 배포 및 스토어 심사 대응 |
| <pre>김경록</pre> | 일기 작성 및 공유 기능 중심 개발, 대표 문서 체계 도입, DeepL API 기반 다국어화 적용 |
| <pre>권세한</pre> | 팀 내 역할 (개발/운영 보조) |
| <pre>박창휘</pre> | 앱 디자인 총괄(UI/UX), 리서치 기반 앱 컨셉 및 브랜딩 전략 수립, UI 디자인 및 디자인 시스템 구축, 디자인 검수 |

---

## 📌 배운 점

- 앱 심사와 서비스 운영 과정에서 발생하는 **실제 문제 해결 경험** 축적  
- 소셜 로그인, 다국어, 네트워크 등 **실무 난이도 높은 문제 해결 능력 확보**  
- 실제 사용자 피드백 기반으로 **지속적인 개선 사이클** 운영  

---

## ✨ 한 줄 소개

**“실서비스를 개발·출시·운영하며, 복잡한 기술적 문제를 해결할 수 있는 풀스택 모바일 개발 경험”**
