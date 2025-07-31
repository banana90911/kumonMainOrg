public without sharing class ContactManagementController {

    @InvocableMethod(
        label='자녀 이름 조회'
        description='학부모의 이름, 이메일, 전화번호를 기반으로 연결된 자녀의 이름을 반환합니다.'
    )
    public static List<List<String>> getChildNames(List<ParentInput> inputs) {

        // 반환할 결과 리스트 (학부모별 자녀 이름 리스트들)
        List<List<String>> results = new List<List<String>>();

        // 입력받은 학부모 정보 하나씩 반복
        for (ParentInput input : inputs) {

            // 해당 학부모에 대한 자녀 이름 리스트
            List<String> childNames = new List<String>();

            List<Account> parents = [
                SELECT Id FROM Account 
                WHERE Name = :input.name 
                AND Phone = :input.phone 
                AND Email__c = :input.email
                LIMIT 1
            ];

            if (!parents.isEmpty()) {
                Id parentId = parents[0].Id;

                List<Contact> children = [
                    SELECT ChildName__c FROM Contact 
                    WHERE AccountId = :parentId
                ];

                for (Contact c : children) {
                    childNames.add(c.ChildName__c);
                }
            } else {
                childNames.add('일치하는 학부모가 없습니다');

            results.add(childNames);
            }
            
        }
        return results;
    }    // Flow에서 입력을 받을 때 사용할 클래스 정의
    
    
    public class ParentInput {
            @InvocableVariable(label='학부모 이름') 
            public String name;

            @InvocableVariable(label='이메일') 
            public String email;

            @InvocableVariable(label='전화번호') 
            public String phone;
        }
}