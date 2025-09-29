<a href="https://club-project-one.vercel.app/" target="_blank">
// 홍보 이미지 넣기
</a>

<br/>
<br/>

# 📝 Front Flutter 소개 


## 💻 0. Getting Started 프로그램 시작하는 법 
- server 깃 코드 다운 받으신 후 프로그램 실행 (IntelliJ , VScode , Eclipse) 등등
- 서버가 돌아가고 있다고 가정하에 Flutter 실행하시면 됩니다 


## 📖 1. Project Overview (프로젝트 개요)
- 프로젝트 이름: Markit_Place 
- 프로젝트 설명: Ai 기술을 활용한 실시간 GPS 중고 거래 커뮤니티 


## 🛠️ 2. Front Flutter 개발 환경 
- **언어** : Dart
- **프레임워크** : Flutter
- **SDK** : Flutter 3.27.4
- **Build Tool** : Gradle (Groovy)
- **의존성 관리** : pubspec.yaml (YAML 기반)


## 🔑 3. Key Features (주요 기능)
- **회원 가입**
  - 아이디 형식 회원 가입 및 이메일 회원 가입
  - 약관 동의 (체크)
  - 중복 체크 및 이메일 인증(google mail 인증방식)
    
- **로그인**
  -  소셜 로그인 (naver,google)
  -  일반 로그인 및 이메일 로그인
    
- **채팅 기능**
  -  1:1 채팅 기능 
  -  WebSocket 사용
  -  STOMP 사용

- **상품 등록**
  - 상품 등록 수정 및 삭제 (중고상품)
  - 상품 신고 하기 (신고 승인 결과 따라 정지 유무 결정)
    - 정지 횟수에 따라 로그인 정지 시간이 정해짐 
      
- **게시물 등록**
  - 게시물 등록 삭제 수정 (커뮤니티)
  - 게시물 신고 하기 (신고 승인 결과 따라 정지 유무 결정)
    - 신고 횟수에 따른 게시물 등록 하지 못하는 시간이 늘어남

- **거래 관리 및 유저 관리**
  - 상품 구매후 리뷰 작성 (리뷰는 해당 판매 유저의 평가에 남는다)
  - 평점 매기기 (유저의 매너 점수를 나타냄 5점 만점)
  - 칭찬하기 (해당 유저의 평점 점수를 올려줌)

- **웹 서버 어드민 기능**
  - 공지사항 작성
  - QnA 관리
  - 상품,커뮤니티 신고 목록 검사하기 (신고 승인)
  - 모든 기능에 접근 가능



## 4. Tasks & Responsibilities (작업 및 역할 분담)
|  |  |  |
|-----------------|-----------------|-----------------|
| 조정우    |  [<img src="https://avatars.githubusercontent.com/u/140272714?v=4" alt="조정우" width="100">](https://github.com/dhdhfkk1119) | <ul><li>프로젝트 계획 및 관리</li><li>채팅,Flutter 레이아웃 작업</li><li>Flutter 상품 및 마이페이지 상태관리</li></ul>     |
| 유류진   |  [<img src="https://avatars.githubusercontent.com/u/208729786?v=4" alt="유류진" width="100">](https://github.com/yooryujin)| <ul><li>Figma 레이아웃</li><li>유저 거래 리뷰 및 평점</li><li>flutter 게시물 등록 수정 삭제</li></ul> |
| 양성빈   |  [<img src="https://avatars.githubusercontent.com/u/197378605?v=4" alt="양성빈" width="100">](https://github.com/ysb5397)    |<ul><li>홈 페이지 개발</li><li>로그인 페이지 개발</li><li>동아리 찾기 페이지 개발</li><li>동아리 프로필 페이지 개발</li><li>커스텀훅 개발</li></ul>  |
| 조충희    |  [<img src="https://avatars.githubusercontent.com/u/105851912?v=4" alt="조충희" width="100">](https://github.com/dovahk11m)    | <ul><li>회원가입 페이지 개발</li><li>마이 프로필 페이지 개발</li><li>커스텀훅 개발</li></ul>    |
| 손지윤    |  [<img src="https://avatars.githubusercontent.com/u/208729868?v=4" alt="손지윤" width="100">](https://github.com/sonjiyoon12)    | <ul><li>회원가입 페이지 개발</li><li>마이 프로필 페이지 개발</li><li>커스텀훅 개발</li></ul>    |
| 황지백    |  [<img src="https://avatars.githubusercontent.com/u/208729937?v=4" alt="황지백" width="100">](https://github.com/jibaek1)    | <ul><li>회원가입 페이지 개발</li><li>마이 프로필 페이지 개발</li><li>커스텀훅 개발</li></ul>    |
| 조현진    |  <img src="https://github.com/user-attachments/assets/beea8c64-19de-4d91-955f-ed24b813a638" alt="조현진" width="100">    | <ul><li>회원가입 페이지 개발</li><li>마이 프로필 페이지 개발</li><li>커스텀훅 개발</li></ul>    |

<br/>
<br/>

## 5. 시현 영상

### 회원정보
<table>
  <tr>
    <td align="center"><b>로그인 </b></td>
    <td align="center"><b>회원가입</b></td>
    <td align="center"><b>소셜 로그인</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/0a4cf10c-630d-45a1-b9db-da277b10787b" alt="로그인" width="250"/>
    </td>
    <td align="center">
      <img src="여기에-상품수정삭제-GIF-주소-붙여넣기" alt="회원 가입" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/77d69377-c050-4e16-9e28-2a916cb034ac" alt="소셜 로그인" width="250"/>
    </td>
  </tr>
</table>

### 상품페이지 
<table>
  <tr>
    <td align="center"><b>상품 등록</b></td>
    <td align="center"><b>상품 수정 삭제</b></td>
    <td align="center"><b>상품 리스트 및 검색 기능</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/d7b61c9c-358a-4d8c-97c1-f1d48e33db0c" alt="상품 등록" width="250"/>
    </td>
    <td align="center">
      <img src="여기에-상품수정삭제-GIF-주소-붙여넣기" alt="상품 수정 삭제" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/77d69377-c050-4e16-9e28-2a916cb034ac" alt="상품 리스트 및 검색 기능" width="250"/>
    </td>
  </tr>
</table>

### 커뮤니티 페이지
<table>
  <tr>
    <td align="center"><b>커뮤니티 등록</b></td>
    <td align="center"><b>커뮤니티 검색</b></td>
    <td align="center"><b>커뮤니티 수정 삭제</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/c92af136-4139-442f-a4ad-b551dc0645a2" alt="커뮤니티 등록" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/b7e9e6b3-50d9-4cfd-a396-3dc25b077b1e" alt="커뮤니티 검색" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/d0a98ffc-0791-408c-b75c-89e6bbb8f1d1
" alt="커뮤니티 수정 삭제" width="250"/>
    </td>
  </tr>
</table>

### 채팅 페이지
<table>
  <tr>
    <td align="center"><b>로그인 유저 채팅 보내기</b></td>
    <td align="center"><b>상대방 채팅 보내기</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/49e655ef-89fb-4633-b27c-b417554c645a" alt="상품 등록" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/49e4862b-2168-4c37-b134-03d7486c1206" alt="상품 수정 삭제" width="250"/>
    </td>
  </tr>
</table>

### 마이 페이지 
<table>
  <tr>
    <td align="center"><b>마이페이지 리스트 페이지</b></td>
    <td align="center"><b>프로필 수정</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/c1fd9553-27ce-4ba0-ba8e-a7074cda22e6" alt="리스트 페이지" width="250"/>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/207fdd05-ec6b-41ef-8f81-fe5ef84f4731" alt="프로필 수정" width="250"/>
    </td>
  </tr>
</table>

