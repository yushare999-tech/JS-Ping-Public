# 🏓 JS-Ping

JS-Ping 프로젝트 저장소입니다.

---

## 📂 프로젝트 디렉토리 트리 구조 (Directory Structure)

```text
JS-Ping/
├── .gitignore          # Git 제외 대상 설정
├── .version            # SemVer 프로젝트 버전 파일 (현재: 4.18.1)
├── git_sync.sh         # [전역 필수] 형상 관리 & 버저닝 자동화 유틸리티
├── publish_ghcr.sh     # 🐳 GHCR 공개 Docker 이미지 게시 유틸리티 (0.X.0)
├── publish_public_repo.sh # 🌐 공개 저장소(JS-Ping-Public) 템플릿 원터치 싱크 유틸리티
├── HISTORY.md          # 최상위 변경 이력 및 문서 네비게이션
├── README.md           # 프로젝트 개요 및 디렉토리 구조
├── Dockerfile          # Multi-stage Docker 이미지 빌드 템플릿
├── Dev/                # 🛠️ [개발 전용 팩] 로컬 소스 수정 후 빠른 재빌드/도커 테스트 전용 디렉토리
│   ├── build_dev.sh        # 로컬 Go 바이너리(build/ping-engine, build/migrator) 3초 전용 재빌드 스크립트
│   ├── run_dev.sh          # 로컬 개발용 백그라운드 엔진 가동 스크립트
│   ├── stop_dev.sh         # 로컬 개발 백그라운드 엔진 안전 중지 스크립트
│   ├── config_dev.yaml     # 로컬 개발 전용 DB & 서버 설정 파일
│   └── README.md           # Dev 개발 패키지 안내서
├── Master/             # 👑 [마스터 노드 팩] 163 마스터 전용 도커 실행 패키지
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── docker_deploy.sh
│   └── config.yaml
├── deploy/             # 🚀 [순수 실무 배포 팩] 공개 레포지토리 싱크 전용 청정 배포 패키지 디렉토리
│   ├── Dockerfile          # Multi-stage 생산 배포용 Dockerfile
│   ├── docker-compose.yml   # 범용 순수 배포용 Docker Compose 템플릿
│   ├── config.yaml.example # DB & 노드 설정 템플릿
│   ├── docker_deploy.sh    # 원클릭 배포 및 자동 구동 스크립트
│   └── README.md           # 배포 팩 설명서
├── web/                # 웹 대시보드 UI (Setup 마법사, 모니터링, RTT 히스토리/부하분석, ACL)
│   ├── index.html          # Setup 마법사, 대시보드, PING 히스토리 로그 뷰어 모달 & RTT 분석 탭 HTML
│   ├── style.css           # 프리미엄 글래스모피즘 디자인 시스템
│   └── app.js              # REST API 연동, Pure JS Canvas RTT 차트 렌더러 & 대시보드 스크립트
├── cmd/
│   ├── migrator/           # DB 마이그레이터 엔트리포인트 (main.go)
│   ├── ping-engine/        # 메인 모니터링 엔진 엔트리포인트 (main.go)
│   └── tools/              # 🛠️ 유틸리티 도구 (update-telegram-menu)
├── internal/
│   ├── alert/              # 텔레그램 다중 알림 그룹 브로드캐스팅 & 슬래시 명령어 처리 엔진
│   ├── api/                # Gin REST API Gateway (analytics.go, handler.go, Hybrid Auth)
│   ├── checker/            # ICMP, HTTP, HTTPS, TCP 수집기 & Worker Pool
│   ├── cluster/            # Node Heartbeat & Optimistic Locking Leasing 엔진
│   ├── config/             # YAML 설정 파서 및 NODE_ROLE 환경변수 파서
│   └── database/           # MySQL DB 접속 커넥션 및 DDL 엔진 (jsping_ 7개 테이블)
├── scripts/
│   ├── telegram_commands.json  # 🤖 텔레그램 슬래시 명령어 외부 JSON 설정 파일
│   ├── update_telegram_menu.sh # 🛠️ 텔레그램 슬래시 메뉴 및 버튼 수동 등록 CLI 도구
│   ├── update_telegram_menu    # 텔레그램 메뉴 수동 등록 실행 바이너리
│   ├── reset_cluster_nodes.sh  # 클러스터 노드 & 임대(Lease) DB 초기화 셸 스크립트
│   └── reset_cluster_nodes.sql # 클러스터 노드 DB 초기화 SQL 쿼리 파일
└── docs/               # 상세 기술 및 설계 문서 디렉토리
    ├── v5.0/               # 🚀 [v5.0 개발 계획 전용 디렉토리]
    │   ├── V5_ROLE_BASED_ARCHITECTURE_AND_HISTORY_VIEWER.md # 🏛️ 역할 기반 아키텍처 & PING 히스토리 뷰어 상세 설계서
    │   ├── MILESTONE_PROGRESS_REPORT.md                     # 🚩 마일스톤 경과 & v5.0 차기 개발 로드맵 보고서
    │   └── DEVELOPMENT_PLAN.md                              # 📐 v5.0 코어 개발 계획서
    ├── AUTO_REBALANCING_DEVELOPMENT_PLAN.md # 📐 [자동 균등 재분배] 노드 Scale-Out PING 대상 Auto-Rebalancing 기술 개발 계획서
    ├── TELEGRAM_BOT_INTEGRATION_SUMMARY.md # [총괄 문서] 텔레그램 봇 양방향 상호작용 통합 요약서
    ├── DOCKER_OPERATIONS_GUIDE.md # [운영 가이드] 도커 생명주기, 자동 재시작 메커니즘 & 실무 명령어 매뉴얼
    ├── MANUAL_TEST_GUIDE_162_165.md # [매뉴얼] 162~165 노드 초기 구축/업그레이드/롤백/차단 테스트 매뉴얼
    └── DOCKER_DEPLOY_GUIDE.md # [공식 배포] Docker 원클릭 설치 & 실무 릴리즈 가이드
```

---

## 🛠️ 개발 및 빌드 가이드 (Quick Start)

### 로컬 개발 및 빠른 빌드 (`Dev/`)
```bash
# 1. 소스 수정 후 3초 로컬 빌드
./Dev/build_dev.sh

# 2. 로컬 개발 엔진 가동
./Dev/run_dev.sh

# 3. 로컬 개발 엔진 중지
./Dev/stop_dev.sh
```

---

## 🛠️ 개발 및 동기화 가이드

### 형상 동기화 (Git Sync)
프로젝트 변경사항을 커밋하고 동기화할 때 표준 유틸리티를 사용합니다:
```bash
./git_sync.sh "커밋 메시지"
```
