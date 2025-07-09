public class RandomIndexGenerator {
    @InvocableMethod(label='Generate Random Index')
    public static List<IndexWrapper> generate(List<IndexWrapper> inputList) {
        List<IndexWrapper> results = new List<IndexWrapper>();
        for (IndexWrapper wrapper : inputList) {
            if (wrapper.inputSizes > 0) {
                Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), wrapper.inputSizes);
                IndexWrapper result = new IndexWrapper();
                result.output = index;
                results.add(result);
            }
        }
        return results;
    }

    public class IndexWrapper {
        @InvocableVariable(label='inputSizes')
        public Integer inputSizes;

        @InvocableVariable
        public Integer output;
    }
}