public without sharing class afGetContact {

    @InvocableMethod(
        label='자녀 이름 조회'
        description='학부모의 이름, 이메일, 전화번호를 기반으로 연결된 자녀의 이름을 반환.'
    )
    public static List<String> getChildNames(List<ParentInput> inputs) {
        // 반환할 결과 리스트 (학부모별 자녀 이름 리스트들)
        List<String> results = new List<String>();

         // 입력받은 학부모 정보 하나씩 반복
        for (ParentInput input : inputs) {
            String parentName = input.parentName;
            String parentEmail = input.parentEmail;
            String parentPhone = input.parentPhone;

            // 학부모 정보 조회
            List<Account> parents = [
                SELECT Id FROM Account
                WHERE Name = :parentName
                AND Phone = :parentPhone
                AND Email__c = :parentEmail
                LIMIT 1
            ];
            // 일치하는 학부모가 있다면
            if (!parents.isEmpty()) {
                Id parentId = parents[0].Id;
                // 해당 학부모(Account)에 연결된 자녀(Contact) 목록 조회
                List<Contact> children = [
                    SELECT ChildName__c FROM Contact
                    WHERE AccountId = :parentId
                ];

                if (!children.isEmpty()) {
                    // 자녀 이름을 쉼표로 연결
                    List<String> childNames = new List<String>();
                    for (Contact c : children) {
                        childNames.add(c.ChildName__c);
                    }
                    String childNamesStr = String.join(childNames, ', ');

                    // 응답 메시지
                    String message = parentName + '님, 커몬학습과 함께해 주셔서 감사합니다! 등록된 자녀는 ' + childNamesStr + '입니다. 무엇을 도와드릴까요?';
                    results.add(message);
                } else {
                    results.add(parentName + '님, 연결된 자녀 정보를 찾을 수 없습니다.');
                }
            } else {
                results.add('일치하는 학부모 정보를 찾을 수 없습니다. 다시 확인해 주세요.');
            }
        }
        // 전체 결과 반환
        return results;
    }
     // Flow에서 입력을 받을 때 사용할 클래스 정의
    public class ParentInput {
        @InvocableVariable(label='학부모 이름')
        public String parentName;

        @InvocableVariable(label='이메일')
        public String parentEmail;

        @InvocableVariable(label='전화번호')
        public String parentPhone;
    }
}