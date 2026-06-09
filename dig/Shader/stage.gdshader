shader_type canvas_item;

// 0.0이면 꺼진 상태1.0이면 완전히 켜진 상태
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    // UV를 가운데(0.5, 0.5)를 기준으로 맞춤
    uv -= 0.5;
    
    // progress에 따라 가로/세로 스케일 변화 계산
    // 가로가 먼저 퍼지고(progress 0~0.3), 세로가 퍼짐(progress 0.3~1.0)
    float scale_x = mix(0.0, 1.0, clamp(progress * 3.33, 0.0, 1.0));
    float scale_y = mix(0.01, 1.0, clamp((progress - 0.3) * 1.42, 0.0, 1.0));
    
    // 0으로 나누는 오류 방지 및 스케일 적용
    if (scale_x > 0.001) uv.x /= scale_x;
    if (scale_y > 0.001) uv.y /= scale_y;
    
    uv += 0.5;
    
    // 화면 밖으로 벗어난 부분은 검은색 처리
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0 || progress == 0.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // 화면 안쪽 렌더링 + 처음 켜질 때 하얀색 플래시 효과 추가
        vec4 tex_color = texture(TEXTURE, uv);
        float flash = 1.0 - clamp(progress * 2.0, 0.0, 1.0);
        COLOR = tex_color + vec4(flash, flash, flash, 0.0);
    }
}