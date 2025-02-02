enum Emotion {
  happiness, // 기쁨
  fear, // 두려움
  discomfort, // 불쾌
  anger, // 분노
  sadness, // 슬픔
  unknown, // 모름
}

class Keyword {
  List<String> largeCategories = ["기쁨", "두려움", "불쾌", "분노", "슬픔", "모름"];

  Map<Emotion, List<String>> emotionMap = {
    Emotion.happiness: [
      "감동적이다",
      "감탄하다",
      "고맙다",
      "괜찮다",
      "궁금하다",
      "기쁘다",
      "다행스럽다",
      "든든하다",
      "만족스럽다",
      "반갑다",
      "뿌듯하다",
      "사랑스럽다",
      "상쾌하다",
      "설레다",
      "신기하다",
      "신나다",
      "여유롭다",
      "열정적이다",
      "유쾌하다",
      "자랑스럽다",
      "자신있다",
      "재미있다",
      "좋다",
      '즐겁다',
      "통쾌하다",
      "편안하다",
      "행복하다",
      "홀가분하다",
      "활기차다",
      "훈훈하다",
      "흥미롭다",
    ],
    Emotion.fear: [
      "걱정스럽다",
      "긴장하다",
      "깜짝 놀라다",
      "당황하다",
      "두렵다",
      "막막하다",
      "망설이다",
      '무력하다',
      "무섭다",
      "부끄럽다",
      "불안하다",
      "심란하다",
      "조마조마하다",
      "주눅들다",
      "혼란스럽다",
    ],
    Emotion.discomfort: [
      "곤란하다",
      "관심없다",
      "귀찮다",
      "부담스럽다",
      "부럽다",
      "불쾌하다",
      "불편하다",
      "싫다",
      "심심하다",
      "어색하다",
      "지루하다",
      "지치다",
      "찜찜하다",
      "피곤하다",
      "황당하다",
    ],
    Emotion.anger: [
      "괘씸하다",
      "나쁘다",
      "답답하다",
      "못마땅하다",
      "밉다",
      "심술나다",
      "어이없다",
      "억울하다",
      "원망스럽다",
      "지긋지긋하다",
      "짜증나다",
      "화나다",
    ],
    Emotion.sadness: [
      "괴롭다",
      "그립다",
      '무기력하다',
      "미안하다",
      "불쌍하다",
      "비참하다",
      "서럽다",
      "서운하다",
      "섭섭하다",
      "속상하다",
      "슬프다",
      "실망스럽다",
      "아쉽다",
      "안타깝다",
      "외롭다",
      "우울하다",
      "절망스럽다",
      "허전하다",
      "후회스럽다",
      "힘들다",
    ],
    Emotion.unknown: [
      "모름",
      "없음",
    ],
  };

  Map<String, List<String>> getEmotionChipOptions() {
    final Map<String, List<String>> emotionChipOptions = {};

    emotionMap.forEach((emotion, keywords) {
      switch (emotion) {
        case Emotion.happiness:
          emotionChipOptions[largeCategories[0]] = keywords;
          break;
        case Emotion.fear:
          emotionChipOptions[largeCategories[1]] = keywords;
          break;
        case Emotion.discomfort:
          emotionChipOptions[largeCategories[2]] = keywords;
          break;
        case Emotion.anger:
          emotionChipOptions[largeCategories[3]] = keywords;
          break;
        case Emotion.sadness:
          emotionChipOptions[largeCategories[4]] = keywords;
          break;
        case Emotion.unknown:
          emotionChipOptions[largeCategories[5]] = keywords;
          break;
      }
    });

    return emotionChipOptions;
  }
}
