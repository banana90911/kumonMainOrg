// 동의 항목 펼침 기능
function toggleContent(id) {
  const el = document.getElementById(id);
  el.style.display = el.style.display === "block" ? "none" : "block";
}

// 전체 동의 시 필수 항목 모두 체크
document.addEventListener("DOMContentLoaded", () => {
  const agreeAll = document.getElementById("agree-all");
  const requiredBoxes = document.querySelectorAll(".required-term");

  agreeAll.addEventListener("change", function () {
    requiredBoxes.forEach((box) => {
      box.checked = this.checked;
    });
  });
});


//자녀 추가 기능
function showSecondChild() {
  const secondForm = document.getElementById('second-child-form');
  const toggleBtn = document.getElementById('toggle-btn');

  if (secondForm.style.display === 'block') {
    secondForm.style.display = 'none';
    toggleBtn.textContent = '+ 자녀 추가';
  } else {
    secondForm.style.display = 'block';
    toggleBtn.textContent = '- 자녀 삭제';
  }
}

//과목 select를 checkboxes로 mapping
const checkboxes = document.querySelectorAll('#checkbox-subjects input[type="checkbox"]');
const select = document.getElementById('00NgK000015uQsT');

checkboxes.forEach(cb => {
  cb.addEventListener('change', () => {
    // select의 모든 option 선택 해제
    Array.from(select.options).forEach(opt => opt.selected = false);

    // 체크된 checkbox 값과 일치하는 select option 선택
    checkboxes.forEach(chk => {
      if (chk.checked) {
        const option = Array.from(select.options).find(opt => opt.value === chk.value);
        if (option) option.selected = true;
      }
    });
  });
});

//지역별 자치구가 뜨게 만들기
const districtsByRegion = {
  '서울': ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'],
  '부산': ['중구', '서구', '동구', '영도구', '부산진구', '동래구', '남구', '북구', '해운대구', '사하구', '금정구', '강서구', '연제구', '수영구', '사상구', '기장군'],
  // 필요 시 다른 지역 추가
};

const regionSelect = document.getElementById('region');
const districtSelect = document.getElementById('district');

regionSelect.addEventListener('change', function () {
  const selectedRegion = this.value;
  const districts = districtsByRegion[selectedRegion] || [];

  // 자치구 옵션 초기화
  districtSelect.innerHTML = '<option value="">--선택--</option>';

  // 자치구 옵션 추가
  districts.forEach(district => {
    const option = document.createElement('option');
    option.value = district;
    option.textContent = district;
    districtSelect.appendChild(option);
  });
});
