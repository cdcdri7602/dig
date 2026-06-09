shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// 인스펙터에서 조절할 수 있는 변수들
uniform float fade_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25; // 가로줄 진하기
uniform float scanline_count = 100.0; // 가로줄 개수
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.15; // 지지직거리는 노이즈 강도
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.003; // 색수차(RGB 어긋남) 강도
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.6; // 테두리 어두워지는 비네팅 강도

// 노이즈 생성을 위한 난수 함수
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // 배경 화면을 가져오기 위해 SCREEN_TEXTURE 사용
    // (SubViewport 안의 CanvasLayer에 있으므로 화면 전체를 캡처해 효과를 줍니다)
    vec2 uv = SCREEN_UV;

    // 1. 색수차 효과 (Chromatic Aberration - 빨간색과 파란색을 양옆으로 살짝 밀어냄)
    float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
    vec3 color = vec3(r, g, b);

    // 2. 가로 스캔라인 (Scanlines - CRT 모니터 특유의 줄무늬)
    float scanline = sin(uv.y * scanline_count * 3.14159 * 2.0) * 0.5 + 0.5;
    color -= vec3(scanline * scanline_intensity);

    // 3. 정적 노이즈 (Static Noise - 지지직거리는 질감, TIME을 더해 매 프레임 변하게 함)
    float noise = random(uv + vec2(TIME * 0.1, TIME * 0.1)); 
    color += vec3(noise * noise_intensity) - (noise_intensity / 2.0);

    // 4. 비네팅 효과 (Vignette - 화면 테두리를 어둡게 하여 폐쇄감 조성)
    float dist = distance(uv, vec2(0.5, 0.5));
    color *= smoothstep(0.8, 0.2, dist * vignette_intensity + 0.2);
	
    // 흑백이나 녹색 톤으로 만들고 싶다면 여기서 color.rgb 값을 조정하면 됩니다.
    // 예시 (녹색 톤): color = color * vec3(0.2, 1.0, 0.3);

    COLOR = vec4(color, 1.0);
	COLOR.a *= fade_alpha;
}