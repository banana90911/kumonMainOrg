# SalesForce CRM101 Project(커몬학습)

<img width="1280" height="406" alt="Image" src="https://github.com/user-attachments/assets/20b06872-54be-44a7-ae36-4c5f0d9085c1" />


```bash
'구몬학습'을 모티브로 세일즈포스 플랫폼을 구축하는 프로젝트로 기업리서치 및 비즈니스 프로세스 분석을 통해 도출한
문제점들을 해결하기 위한 솔루션('업무 자동화', '데이터 통합', '커뮤니케이션 채널 일원화' 등)을 설계하고 구현하는 프로젝트입니다.
```

---

## 1️⃣ 프로젝트 개요

### 🚩 기획 배경 
프로젝트 팀원들은 기존 구몬학습의 운영 방식에서 다음과 같은 비효율을 체감했습니다.
- 신규 고객의 유입부터 재등록까지 전 과정의 산출물이 엑셀로 관리되어, 지역별로 **데이터가 분산되고 연계성이 부족함**
- 아동의 학습 내용과 일정이 각 방문교사 개별 툴에 따로 기록되어, 학습 이력 확인과 일정 관리가 **체계적으로 이루어지지 않음**
- 고객센터에서는 고객 정보를 한눈에 파악하기 어려워 **상담 효율이 떨어지고**, 운영 시간 외에는 응대가 어려움

### 🚩 프로젝트 목표 
이러한 문제를 해결하기 위해 다음과 같은 방향으로 솔루션을 설계하고 구현했습니다.
- 방문 교사나 지사 담당자가 바뀌어도 업무가 단절되지 않도록, 고객 여정 전반의 구조화와 **데이터 통합**을 통한 **체계적인 고객 관리**
- 아동 단위로 학습 진행 상황을 확인할 수 있어, 학습 이력과 교사 일정이 **효율적**으로 관리됨
- 고객 문의 유형별 이력을 기록하고, 유형에 따라 **유동적**으로 대응 가능한 상담 이력 관리 시스템 구축

#### 🖼 페르소나별 AS-IS/TO-BE: 
**CS:**<br>
<img width="1148" height="500" alt="Image" src="https://github.com/user-attachments/assets/829d27f1-3b01-4267-a699-8a4230fab990" />

**방문교사:**<br>
<img width="1146" height="500" alt="Image" src="https://github.com/user-attachments/assets/9cf998e3-2967-4374-981c-765059959537" />

**영업 지사 담당자:**<br>
<img width="1148" height="499" alt="Image" src="https://github.com/user-attachments/assets/67aa8026-a2c5-465c-8aa8-7f0d8a2b577b" />

### 🚩 프로젝트 확장성 
이번 프로젝트는 고객 만족도 향상을 기반으로 데이터 통합 이후 다음과 같은 확장 가능성을 염두에 두고 있습니다.
- 고객이 직접 상담 시간을 예약하고 교사를 선택할 수 있는 **에이전트포스 기반 예약 시스템**
- 고객 여정 기반의 **마케팅 자동화**
- 상담 이력 데이터를 활용한 고객 **리텐션 분석 및 개선 전략 수립**

---

##  2️⃣ 팀원 소개
### 🚩 팀원 및 역할 
| **이름** | **역할** | **GitHub** |
|--------|---------|------------|
| 박예진 | Admin (PM) | [GitHub](https://github.com/) |
| 장연우 | Admin | [GitHub](https://github.com/) |
| 김세빈 | Developer (PL) | [GitHub](https://github.com/) |
| 정시헌 | Developer | [GitHub](https://github.com/) |
| 김성준 | Developer | [GitHub](https://github.com/) |

---

## 3️⃣ 프로젝트 프로세스
### 🖼 프로세스 다이어그램: 
<img width="2514" height="1726" alt="Image" src="https://github.com/user-attachments/assets/22b0dac0-c224-4945-9744-adf5e1279b48" />


---

## 4️⃣ ERD (Entity-Relationship Diagram)

🚩 **ERD 설명:** 데이터베이스 구조 및 관계 설명

🖼 **ERD 이미지:**
<br>
<img width="1766" height="1100" alt="Image" src="https://github.com/user-attachments/assets/9cf86758-ee7c-4555-b463-a054a6811ab6" />

---

## 5️⃣ 요구사항 명세서

### 🚩 기능별 요구사항 정리 
<img width="1399" height="1005" alt="Image" src="https://github.com/user-attachments/assets/1668ec19-3bf0-4f8e-9053-ed741787f6c9" />

---

## 6️⃣ 오브젝트 정의
### 🚩 사용한 오브젝트 이름 및 설명
<img width="937" height="328" alt="Image" src="https://github.com/user-attachments/assets/a2353f62-21e6-4900-97b9-f624e460bc1d" />

---

## 7️⃣ Pain Point별 Solution
### 🚩1. 방문 교사/지사의 수작업 고객 관리
### 기대효과:
- 고객 여정 전체 구조화로 체계적인 고객 관리
-  1. 신규 인입시, 상담사 자동 배정
-  2. 방문교사의 일관되고 체계적인 학습 설명 및 금액 안내

### 도입 기능 및 구현 상세:

**Web-to-Lead**: Experience Cloud를 활용하여 홈페이지에서 상담 신청 시 Lead 자동 생성. 필수 필드 미기입 시 제출 불가 처리 포함.  

**Apex 기반 스코어링 로직**: 리드 생성 시 지역, 과목, 담당 리드 수, 교사 입사일 등 복합 조건에 따라 교사 점수를 산정  

**Omni-Channel 라우팅**: 스코어가 가장 높은 교사에게 리드 수락 기회를 제공. 교사는 웹 환경에서 리드를 실시간 수락할 수 있음  

**모바일 최적화된 리드 전환 프로세스**: 모바일에서도 교사가 리드 확인 후 바로 전환 → 계약 → 구독 내역 전송까지 원클릭 처리  

### 📽 **영상: Web-to-Lead → 리드 자동 배정 → 리드 전환**

https://github.com/user-attachments/assets/41169ca6-856e-496f-9c3a-bf816f51b833

**원클릭 계약 및 계약서 생성**: 불필요한 과정 필요 없이 아동 페이지에서 원클릭으로 계약 생성. 계약 페이지에서 계약서 생성 후 학부모에게 아동 구독 정보 자동 이메일 전송.

**📽영상: 구독내역 → 계약 생성 → 계약서 생성 및 자동 이메일 전송**

https://github.com/user-attachments/assets/2d6dfd74-0de6-4e27-b1d4-aaad1dce6050

<br>

### 🚩2. 분산된 방문교사의 일정 및 학습 관리
### 기대효과:
- 아동에 따른 과정 진행 확인으로 인한 전반적인 학습 이력 및 교사 일정 관리 가능
-  1. 학습 이력 관리 + 학습 이력에 따른 Agentforce 줄거리 요약 기능
-  2. 방문교사 손쉬운 일정 관리

**학습 일정 등록 컴포넌트 (LWC)**: 아동 상세 페이지 내 학습 일정 등록 가능. 구독 내역에 따라 방문 주기 자동 계산  

**Salesforce Calendar 연동**: 등록된 일정은 Salesforce Calendar에서 교사별로 자동 집계 및 조회 가능  

**학습일지 입력 컴포넌트 (LWC)**: 선택형 입력(픽리스트) 기반으로 오류 및 누락 방지. 작성된 일지는 아동 구독과 연동  

**Agentforce 요약 기능**: 교사는 Agentforce에 "오늘 일정 알려줘" 또는 "태하 학습 요약 보여줘" 요청 시, 학습일지 요약 응답 수신  

**AI 이메일 발송 버튼**: 학부모 요청 시, 최신 학습 요약 이메일 자동 전송

<br>

### 🚩3. 부서 간 협업 부재
### 기대효과:
- 고객 문의 유형별 이력 관리 및 문의 유형별 유동적인 CS 문의 관리
-  1. 챗봇 활용하여 일반문의 관리
-  2. 케이스 이력 관리 및 클레임 문의 CS 담당자가 Web-to-case 로 문의 처리 및 영업지사에게 Case 할당하여 Case 해결 (Customer 360)

**Web-to-Case (Experience Cloud)**: 홈페이지 내 문의폼 → 케이스 자동 생성  

**Omni-Channel & Dynamic Queue Assignment**: 문의 유형(예: 학습 현황, 불만 접수 등)에 따라 알맞은 큐에 자동 배정  

**Agentforce 챗봇 연동**: 고객이 웹에서 직접 챗봇을 통해 실시간 응답 가능.  
  - 예: “우리 아이 학습 현황 알려줘” → 학습일지 기반 요약 응답  
  - “추천 과목 알려줘” → 학습 데이터 기반 과정 추천 + 교사에게 문의 전달  

**케이스 관리 뷰 구성 (LWC)**: 담당 교사 및 지사 담당자는 케이스 목록, 학부모, 아동 정보를 연결해 통합 조회 가능  


---

## 8️⃣ 기술 스택 세부 명세
### 📌 프로젝트에서 사용된 주요 기술 스택 

### 💻 Backend 
- ![Apex](https://img.shields.io/badge/Apex-0055CC?style=flat&logo=salesforce&logoColor=white)
- ![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)
- ![SFDX](https://img.shields.io/badge/SFDX-00A1E0?style=flat&logo=salesforce&logoColor=white)

### 🎨 Frontend 
- ![LWC](https://img.shields.io/badge/LWC-0070D2?style=flat&logo=salesforce&logoColor=white)
- ![html](https://img.shields.io/badge/html-3366CC?logo=htmx&logoColor=white&labelColor=3366CC)

### 🗄 Database 
- ![SOQL](https://img.shields.io/badge/SOQL-00A1E0?style=flat&logo=salesforce&logoColor=white)

### 🛠 협업 툴 
- ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)
- ![Jira](https://img.shields.io/badge/Jira-0052CC?style=flat&logo=jira&logoColor=white)
- ![Notion](https://img.shields.io/badge/Notion-000000?style=flat&logo=notion&logoColor=white)
- ![Figma](https://img.shields.io/badge/Figma-F24E1E?logo=figma&logoColor=white&labelColor=F24E1E)
- ![Sheets](https://img.shields.io/badge/Sheets-34A853?logo=googlesheets&logoColor=white&labelColor=34A853)
