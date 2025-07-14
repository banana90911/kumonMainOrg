public class TeacherScoreWrapper implements Comparable {
    public Id teacherId;
    public Decimal score;

    public TeacherScoreWrapper(Id id, Decimal s) {
        teacherId = id;
        score = s;
    }

    public Integer compareTo(Object obj) {
        TeacherScoreWrapper other = (TeacherScoreWrapper)obj;
        if (this.score > other.score) return -1;
        if (this.score < other.score) return 1;
        return 0;
    }
}