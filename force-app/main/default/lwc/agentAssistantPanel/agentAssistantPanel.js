import { LightningElement } from 'lwc';

export default class AgentAssistantPanel extends LightningElement {
    openAgent() {
        try {
            // 최신 버전에서 지원되는 Agentforce(Copilot) 호출 방식
            if (window.openCopilot && typeof window.openCopilot === 'function') {
                window.openCopilot(); // 공식 메서드가 존재하면 호출
            } else {
                // Copilot 인터페이스가 없을 경우 사용자에게 안내
                alert('현재 Copilot 인터페이스를 사용할 수 없습니다. 관리자에게 문의하세요.');
            }
        } catch (error) {
            console.error('에이전트 호출 중 오류:', error);
            alert('에이전트 호출에 실패했습니다. 관리자에게 문의하세요.');
        }
    }
}
