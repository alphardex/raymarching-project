/*
球体的SDF函数
s: 球体半径
*/
// float sphereSDF(vec3 p,float s){...}

/*
椭圆体的SDF函数
r: 椭圆体大小，x代表长度，y代表高度，z代表厚度
*/
// float ellipsoidSDF(in vec3 p,in vec3 r){...}

/*
圆锥的SDF函数
r1: 底部半径
r2: 顶部半径
h：高度
*/
// float coneSDF(in vec3 p,in float r1,float r2,float h){...}

/*
方块的SDF函数
b：方块大小，x代表长度，y代表高度，z代表厚度
*/
// float boxSDF(vec3 p,vec3 b){...}

#define RESOLUTION iResolution.xy// 分辨率
#define RAYMARCH_SAMPLES 128// 采样次数（即步进次数）
#define RAYMARCH_MULTISAMPLE 1// 多重采样次数（即抗锯齿次数）
#define RAYMARCH_BACKGROUND vec3(0.)// 背景色
#define RAYMARCH_CAMERA_FOV 2.// 相机视场角

#define COLOR_1 vec3(.757,.765,.729)
#define COLOR_2 vec3(.553,.239,.227)
#define COLOR_3 vec3(.278,.039,.063)
#define COLOR_4 vec3(.001,.001,.001)
#define COLOR_5 vec3(.745,.596,.341)
#define COLOR_6 vec3(.302,.082,.098)

#include "/node_modules/lygia/space/ratio.glsl"

#define RAYMARCH_MATERIAL_FNC raymarchCustomMaterial
vec3 raymarchCustomMaterial(vec3 ray,vec3 pos,vec3 nor,vec3 map);

#include "/node_modules/lygia/lighting/raymarch.glsl"
#include "/node_modules/lygia/sdf.glsl"
#ifndef opRepeat
#define opRepeat opRepite
#endif

vec3 worldPosToJumpyDumpty(vec3 p){
    p.x-=1.5;
    p.z-=iTime*2.;
    p.y-=abs(sin(iTime*5.))*.2;
    p=opRepeat(p,vec3(3.));
    return p;
}

vec3 raymarchCustomMaterial(vec3 ray,vec3 pos,vec3 nor,vec3 map){
    vec3 posOrigin=pos;
    
    if(sum(map)<=0.){
        return RAYMARCH_BACKGROUND;
    }
    
    vec3 col=vec3(0.);
    
    col+=map*.2;
    
    vec3 lightPos=vec3(10.);
    vec3 lightDir=normalize(lightPos-pos);
    float diff=max(dot(lightDir,nor),0.);
    float shadow=raymarchSoftShadow(pos,lightDir,.05,1.5);
    col+=map*diff*shadow;
    
    vec3 reflectDir=reflect(-lightDir,nor);
    vec3 viewDir=normalize(-ray);
    vec3 halfVec=normalize(lightDir+viewDir);
    float spec=pow(max(dot(nor,halfVec),0.),32.);
    col+=map*spec;
    
    if(pos.y>2.){
        return RAYMARCH_BACKGROUND;
    }
    
    pos=worldPosToJumpyDumpty(pos);
    
    if(map==COLOR_1){
        // head
        
        // eye
        vec2 uv1=pos.xy;
        uv1.x=abs(uv1.x);
        uv1/=vec2(.75,.5);
        uv1-=vec2(-.15,.4);
        float c1=circleSDF(uv1);
        float eye=1.-smoothstep(.15,.151,c1);
        col=mix(col,COLOR_3,eye);
        
        // mouth
        vec2 uv2=pos.xy;
        uv2.x=abs(uv2.x);
        uv2.y-=.4;
        uv2.y*=-1.;
        float c2=lineSDF(uv2,vec2(0.),vec2(.05));
        float mouth=1.-smoothstep(.0125,.01251,c2);
        col=mix(col,COLOR_3,mouth);
    }else if(map==COLOR_4){
        // belt
        vec2 uv3=pos.xy;
        uv3/=vec2(.4);
        uv3-=vec2(-.5,-.18);
        uv3=fract(uv3);
        float c3=circleSDF(uv3);
        float polka=1.-smoothstep(.15,.151,c3);
        col=mix(col,COLOR_5,polka);
    }else if(map==COLOR_2){
        // body
        
        vec2 uv4=pos.xy;
        uv4/=vec2(.4);
        uv4-=vec2(-.5,.05);
        uv4.y/=.6;
        uv4.y*=-1.;
        float c4=triSDF(uv4);
        float tri=1.-smoothstep(1.8,1.81,c4);
        col=mix(col,COLOR_6,tri);
        
        vec2 uv5=pos.xy;
        uv5/=vec2(.4);
        uv5-=vec2(-.5,-1.05);
        float c5=uv5.y;
        float stripe=smoothstep(.09,.1,c5)-smoothstep(.19,.2,c5);
        col=mix(col,COLOR_5,stripe);
        
        vec2 uv6=pos.xy;
        uv6/=vec2(.4);
        uv6-=vec2(-.7,-1.9);
        uv6.y/=.7;
        uv6.x/=1.4;
        float c6=heartSDF(uv6);
        float heart=1.-smoothstep(1.8,1.81,c6);
        col=mix(col,COLOR_5,heart);
    }
    
    // fog
    float fog=exp(-.000005*pow(posOrigin.z,6.));
    col=mix(col,RAYMARCH_BACKGROUND,1.-fog);
    
    return col;
}

vec4 jumpyDumpty(vec3 p,vec4 res){
    // head
    vec3 p1=p;
    float head=sphereSDF(p1,.69);
    head=opIntersection(head,boxSDF(p1-vec3(0.,1.3,0.),vec3(1.)));
    res=opUnion(res,vec4(COLOR_1,head));
    
    // ear
    vec3 p2=p;
    p2.x=abs(p2.x);
    float ear=ellipsoidSDF(rotate(p2-vec3(.45,.7,0.),-PI/3.,vec3(0.,0.,1.)),vec3(.1,.25,.1));
    res=opUnion(res,vec4(COLOR_1,ear),.025);
    
    // body
    vec3 p3=p;
    p3.y-=.3;
    p3.y/=.8;
    float body=coneSDF(p3-vec3(0.,-.6,0.),.75,.5,1.);
    body=opIntersection(body,boxSDF(p3-vec3(0.,-1.,0.),vec3(1.)));
    body*=.8;
    res=opUnion(res,vec4(COLOR_2,body));
    
    // skirt
    vec3 p4=p;
    p4.y-=.14;
    p4.y/=.8;
    p4/=1.05;
    p4.y*=-1.;
    float skirt=coneSDF(p4-vec3(0.,-.6,0.),.75,.5,1.);
    skirt=opIntersection(skirt,boxSDF(p4-vec3(0.,-1.,0.),vec3(1.)));
    skirt*=.8;
    p4*=1.05;
    skirt=opIntersection(skirt,boxSDF(p4-vec3(0.,.8,0.),vec3(1.)));
    res=opUnion(res,vec4(COLOR_2,skirt));
    
    // belt
    vec3 p5=p;
    p5.y-=.24;
    p5.y/=.8;
    p5/=1.04;
    float belt=coneSDF(p5-vec3(0.,-.6,0.),.75,.5,1.);
    belt=opIntersection(belt,boxSDF(p5-vec3(0.,-1.,0.),vec3(1.)));
    belt*=.8;
    p5*=1.04;
    belt=opIntersection(belt,boxSDF(p5-vec3(0.,.8,0.),vec3(1.)));
    res=opUnion(res,vec4(COLOR_4,belt));
    
    return res;
}

vec4 raymarchMap(vec3 p){
    vec4 res=vec4(1.);
    // res=opUnion(res,vec4(vec3(.875,.286,.333),sphereSDF(p-vec3(0.,0.,-2.),1.)));
    
    vec3 p1=p;
    p1=worldPosToJumpyDumpty(p1);
    res=jumpyDumpty(p1,res);
    
    vec3 p2=p;
    res=opUnion(res,vec4(vec3(1.),planeSDF(p2)+.75));
    
    return res;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 uv=fragCoord/iResolution.xy;
    uv=ratio(uv,iResolution.xy);
    vec3 col=vec3(0.);
    // vec3 camera=vec3(0.,10.,30.);
    vec3 camera=vec3(-30.,15.,50.);
    col=raymarch(camera,uv).rgb;
    fragColor=vec4(col,1.);
}
