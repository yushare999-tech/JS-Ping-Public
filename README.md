# 🏓 JS-Ping Official Public Release Node

본 패키지는 **JS-Ping Active-Active 클러스터 분산 모니터링 엔진**의 원터치 배포 및 가동을 위한 퍼블릭 전용 구동 패키지입니다. 
GitHub Container Registry(`ghcr.io/yushare999-tech/js-ping-node:latest`)의 최신 검증 릴리즈 이미지를 활용하여 안전하고 원터치로 캡슐화 실행됩니다.

---

## ⚡ 1초 원터치 빠른 설치 (One-Line Quick Install)

터미널에서 아래 한 줄 명령어를 입력하면 자동으로 최신 이미지 수신부터 `config.yaml` 템플릿 세팅 및 컨테이너 구동까지 원스톱으로 진행됩니다.

```bash
curl -sSL https://raw.githubusercontent.com/yushare999-tech/JS-Ping-Public/main/deploy.sh | bash
```

### 🧹 원터치 한방 초기화 / 삭제 (One-Touch Reset)
노드를 완전 초기화하거나 재설치하려는 경우 아래 명령어를 실행합니다:

```bash
curl -sSL https://raw.githubusercontent.com/yushare999-tech/JS-Ping-Public/main/reset.sh | bash
```

---

## 🚀 수동 Git Clone 설치 및 실행 가이드

### 1단계: 패키지 내려받기
```bash
git clone https://github.com/yushare999-tech/JS-Ping-Public.git js-ping
cd js-ping
```

### 2단계: 배포 스크립트 실행
```bash
./deploy.sh
```
- **자동 검증 및 보정**: 스크립트 실행 시 `config.yaml` 파일 부재에 따른 도커 마운트 디렉토리 생성 버그를 원천 차단하기 위해 기본 안전 템플릿을 자동 생성한 후 컨테이너를 구동합니다.

### 3단계: 웹 마법사 초기 설정
브라우저를 열고 접속합니다.
- **주소**: `http://<서버IP>:8080`
- DB 설정 정보가 비어있는 상태에서 접속 시 **웹 설정 마법사**가 자동으로 표시됩니다. MySQL 접속 정보를 입력하면 테이블 생성 및 노드 등록이 원스톱 처리됩니다.

---

## 🏛️ 네트워크 모드 및 노드 설정 (Host Network Mode)

본 배포 패키지는 **`network_mode: "host"` 표준 규격**을 채택하고 있습니다.
* **실제 사설/공인 IP 100% 보존**: 도커 가상 IP(`172.18.0.x`) 변환(SNAT) 없이 서버의 실제 사설 IP(`10.96.x.x`, `192.168.0.x`)가 그대로 보존되어 마스터 및 다른 노드에 인식됩니다.
* **PING 측정 속도 정밀화**: 도커 브릿지 나트 레이어를 우회하여 0.1ms 단위의 쾌속 핑 RTT 측정이 가능합니다.

`config.yaml` 파일에서 노드의 망(Zone) 구분을 손쉽게 설정할 수 있습니다:

```yaml
server:
  node_id: ""
  zone: "external"    # Options: internal, external
  listen_port: 8080
```

* **`full` / `worker` / `master`**: PING 측정 수집 및 Auto-Rebalancing(자동 균등 분할) 참여
* **`monitor`**: PING 수집 부하 0% 상태로 오직 웹 대시보드 및 API 서빙만 전담

---

## 🛠️ 클러스터 임대 초기화 도구

노드가 비정상 종료되거나 점유 락을 리셋하려는 경우:
```bash
./scripts/reset_cluster_nodes.sh
```
