shader_type canvas_item;

// 인스펙터에서 조절할 수 있는 변수들 (Uniforms)
uniform vec4 fanfare_color : source_color = vec4(1.0, 0.9, 0.2, 1.0); // 기본 노란색
uniform float ray_count = 32.0;     // 빛 갈래의 개수
uniform float speed = 1.5;          // 회전 속도 (음수면 반대로 회전)
uniform float blur = 0.05;          // 빛 경계선의 부드러움 정도
uniform float mask_size = 0.45;     // 전체 팡파레의 바깥쪽 크기
uniform float clear_center = 0.3;   // 가운데 아이템을 위해 비워둘 공간 크기

void fragment() {
    // 1. UV 좌표를 0.0 ~ 1.0 에서 -0.5 ~ 0.5 로 변경하여 중심을 (0,0)으로 맞춤
    vec2 uv = UV - vec2(0.5); 
    
    // 중심으로부터의 거리(radius)와 현재 픽셀의 각도(angle) 계산 (극좌표계 변환)
    float dist = length(uv);  
    float angle = atan(uv.y, uv.x); 

    // 2. 방사형(집중선) 패턴 생성 및 회전
    // TIME 변수를 더해 시간이 지남에 따라 각도가 돌아가게 만듦
    float pattern = sin(angle * ray_count + TIME * speed);
    
    // 경계선을 부드럽게(혹은 날카롭게) 처리
    pattern = smoothstep(-blur, blur, pattern);

    // 3. 원형 마스크 적용 (네모난 ColorRect를 둥글게 자르고 가운데를 뚫음)
    // 바깥쪽은 부드럽게 투명해짐
    float outer_mask = smoothstep(mask_size, mask_size - 0.1, dist);
    // 안쪽(중심)은 부드럽게 나타남 (아이템이 묻히지 않게)
    float inner_mask = smoothstep(clear_center, clear_center + 0.1, dist);
    
    float final_mask = outer_mask * inner_mask;

    // 4. 최종 색상 및 투명도(Alpha) 적용
    COLOR = fanfare_color;
    COLOR.a *= pattern * final_mask; // 패턴과 마스크를 투명도에 곱함
}