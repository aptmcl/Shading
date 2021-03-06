// Geometry shader
const GLchar* geometryShaderSrc = GLSL(
    layout(points) in;
    layout(triangle_strip, max_vertices = 128) out;

    uniform vec3 cameraPos;
    uniform vec3 lookat;
	uniform mat4 MVP;

    in int vSides[];
	in float vScale[];
    in int vType[];
    in mat4 vMat[];
	in float vRatio[];

    out vec4 gColor;

    const float PI = 3.1415926;
    mat4 tMat = vMat[0];
	
    //mat4 vMat[0] = calcRotation();
    vec4 aux = MVP * tMat * gl_in[0].gl_Position;

    float rand(vec2 co){
        return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    }

    int calcSides(int sides){
        float dist = distance(aux,vec4(cameraPos,1.0));
        if(dist > vScale[0]*2){
             return  int(min(sides,max(4.0,(vScale[0]/dist)*(vSides[0]*30.0))));
        }
        return sides;
    }

    //float topColor = rand((tMat * gl_in[0].gl_Position).xy)*0.5+0.25;

    void makeRegSurface(float width, float l, int sides){

        // Safe, GLfloats can represent small integers exactly
        for (int i = 0; i <= sides; i++) {
            // Angle between each side in radians
            float ang = ((PI * 2.0) / sides * i) + vRatio[0];
            if(i%2==(sides%2)){
                gl_Position = aux + MVP * tMat *  vec4(0.0,0.0,0.0,1.0);
                EmitVertex();
            }
            // Offset from center of point (0.3 to accomodate for aspect ratio)
            gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, 0.0, 1.0);
            EmitVertex();
        }
        EndPrimitive();

    }
	void makeTriangle(){
		for(int i = 0;i<3;i++){
			gl_Position = MVP * vec4(tMat[i][0],tMat[i][1],tMat[i][2],1.0);
			EmitVertex();
		}
		EndPrimitive();			
	}
	
	//ERROR: PROBABLY CODE JUNK
	void makeExtrusion(int n,float h){
		vec4 normal = vec4(cross(vec3(tMat[0][0],tMat[0][1],tMat[0][2])-vec3(tMat[1][0],tMat[1][1],tMat[1][2]),
								 vec3(tMat[1][0],tMat[1][1],tMat[1][2])-vec3(tMat[2][0],tMat[2][1],tMat[2][2]))*h,1.0);
		for(int i = 1;i<n && i<4;i++){
			gl_Position = MVP * vec4(tMat[0][0],tMat[0][1],tMat[0][2],1.0);
			EmitVertex();
			gl_Position = MVP * vec4(tMat[i][0],tMat[i][1],tMat[i][2],1.0);
			EmitVertex();
		}
		EndPrimitive();
		for(int i = 1;i<n && i<4;i++){
			gl_Position = MVP * vec4(tMat[0][0],tMat[0][1],tMat[0][2],1.0) +  MVP * normal;
			EmitVertex();
			gl_Position = MVP * vec4(tMat[i][0],tMat[i][1],tMat[i][2],1.0)  +  MVP * normal;
			EmitVertex();
		}
		EndPrimitive();
	}
	void irregularPyramid3(){
		vec4 p0 = vec4(tMat[0][0],tMat[0][1],tMat[0][2],1.0);
		vec4 p1 = vec4(tMat[3][0],tMat[3][1],tMat[3][2],1.0);
		vec3 lenghts = vec3(tMat[1][0],tMat[1][1],tMat[1][2]);
		vec3 angles = vec3(tMat[2][0],tMat[2][1],tMat[2][2]);

		for (int i = 0; i < 3; i++) {
			gl_Position = MVP * p0 + MVP * vec4(cos(angles[i]) * lenghts[i], -sin(angles[i]) * lenghts[i], 0.0, 1.0);
			EmitVertex();
		}
		gl_Position = MVP * p0 + MVP * vec4(cos(angles[0]) * lenghts[0], -sin(angles[0]) * lenghts[0], 0.0, 1.0);
		EmitVertex();
		EndPrimitive();

		for (int i = 0; i < 3; i++) {
			gl_Position = MVP * p0 + MVP * vec4(cos(angles[i]) * lenghts[i], -sin(angles[i]) * lenghts[i], 0.0, 1.0);
			EmitVertex();

			gl_Position = MVP * p1;
			EmitVertex();
		}
		gl_Position = MVP * p0 + MVP * vec4(cos(angles[0]) * lenghts[0], -sin(angles[0]) * lenghts[0], 0.0, 1.0);
		EmitVertex();
		EndPrimitive();
	
	}

	void makePoint(float w0, float l0,float h0){
            int texAux=0;
			float dist = 1.0;
			//distance(aux,vec4(cameraPos,1.0))/80.0;
			float alpha = PI/4;
			float h = h0 * dist;
			float width = w0/(cos(alpha))*dist;
			float l = l0/(cos(alpha))*dist;
			int sides = 4;
            vec4 gColorAux = gColor;
            for (int i = 0; i <= sides; i++,texAux+=8) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i);

				gColor = gColorAux * vec4(vec3((sin(ang)+1)*0.4+0.2),1.0);
				gl_Position = aux + MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                EmitVertex();

                //gColor = gColorAux;
                gl_Position = aux + MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, h, 1.0);
                EmitVertex();

            }
            EndPrimitive();

			gColor = gColorAux;
            // Safe, GLfloats can represent small integers exactly
            for (int i = 0; i <= sides; i++) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i);
                if(i%2==(sides%2)){
                    gl_Position = aux + MVP * tMat * vec4(0.0f,0.0f,-h,1.0f);
                    EmitVertex();
                }

                //gColor = vec4(1.0,0.5,0.0,1.0);
                // Offset from center of point (0.3 to accomodate for aspect ratio)
                gl_Position = aux + MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                EmitVertex();

            }
            EndPrimitive();
            //gColor = gColorAux;
            // Safe, GLfloats can represent small integers exactly
            for (int i = 0; i <= sides; i++) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i);
                if(i%2==(sides%2)){
                    gl_Position = aux + MVP * tMat * vec4(0.0f,0.0f,h,1.0f);
                    EmitVertex();
                }
                //gColor = vec4(topColor,topColor,topColor,1.0);
                // Offset from center of point (0.3 to accomodate for aspect ratio)
                gl_Position = aux + MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, h, 1.0);
                EmitVertex();

            }
            EndPrimitive();
    }

    void makePrism(float w0, float l0,float h, int sides){
			float alpha = PI/sides;
			float width = w0/cos(alpha);
			float l = l0/cos(alpha);
            int texAux=0;
            vec4 gColorAux = gColor;
            for (int i = 0; i <= sides; i++,texAux+=8) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i) + (PI / 4);


                //gColor = vec4((sin(ang/15)+1)*0.5,(sin(ang/15)+1)*0.5,(sin(ang/15)+1)*0.5,1.0);
                //gColor = gColor * (sin(ang)+1)*0.5;
				gColor = gColorAux * vec4(vec3((sin(ang)+1)*0.4+0.2),1.0);
				gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                EmitVertex();

                //gColor = gColorAux;
                gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, h, 1.0);
                EmitVertex();

            }
            EndPrimitive();

			gColor = gColorAux;
            // Safe, GLfloats can represent small integers exactly
            for (int i = 0; i <= sides; i++) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                if(i%2==(sides%2)){
                    gl_Position = aux + MVP * tMat *  vec4(0.0f,0.0f,-h,1.0f);
                    EmitVertex();
                }

                //gColor = vec4(1.0,0.5,0.0,1.0);
                // Offset from center of point (0.3 to accomodate for aspect ratio)
                gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                EmitVertex();

            }
            EndPrimitive();
            //gColor = gColorAux;
            // Safe, GLfloats can represent small integers exactly
            for (int i = 0; i <= sides; i++) {
                // Angle between each side in radians
                float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                if(i%2==(sides%2)){
                    gl_Position = aux + MVP * tMat *  vec4(0.0f,0.0f,h,1.0f);
                    EmitVertex();
                }
                //gColor = vec4(topColor,topColor,topColor,1.0);
                // Offset from center of point (0.3 to accomodate for aspect ratio)
                gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, h, 1.0);
                EmitVertex();

            }
            EndPrimitive();
    }



	void makeTrunk(float w0, float l0,float h, int sides, float ratio){
				float alpha = PI/sides;
				float width = w0/cos(alpha);
				float l = l0/cos(alpha);
                int texAux=0;
                vec4 gColorAux = gColor;
				float width1 = width * ratio;
				float l1 = l * ratio;
                for (int i = 0; i <= sides; i++,texAux+=8) {
                    // Angle between each side in radians
                    float ang = ((PI * 2.0) / sides * i) + (PI / 4);


                    //gColor = vec4((sin(ang/15)+1)*0.5,(sin(ang/15)+1)*0.5,(sin(ang/15)+1)*0.5,1.0);
                    //gColor = gColor * (sin(ang)+1)*0.5;
					gColor = gColorAux * vec4(vec3((sin(ang)+1)*0.4+0.2),1.0);
					gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                    EmitVertex();

                    //gColor = gColorAux;
                    gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width1, -sin(ang) * l1, h, 1.0);
                    EmitVertex();

                }
                EndPrimitive();

				gColor = gColorAux;
                // Safe, GLfloats can represent small integers exactly
                for (int i = 0; i <= sides; i++) {
                    // Angle between each side in radians
                    float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                    if(i%2==(sides%2)){
                        gl_Position = aux + MVP * tMat *  vec4(0.0f,0.0f,-h,1.0f);
                        EmitVertex();
                    }

                    //gColor = vec4(1.0,0.5,0.0,1.0);
                    // Offset from center of point (0.3 to accomodate for aspect ratio)
                    gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                    EmitVertex();

                }
                EndPrimitive();
                //gColor = gColorAux;
                // Safe, GLfloats can represent small integers exactly
                for (int i = 0; i <= sides; i++) {
                    // Angle between each side in radians
                    float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                    if(i%2==(sides%2)){
                        gl_Position = aux + MVP * tMat *  vec4(0.0f,0.0f,h,1.0f);
                        EmitVertex();
                    }
                    //gColor = vec4(topColor,topColor,topColor,1.0);
                    // Offset from center of point (0.3 to accomodate for aspect ratio)
                    gl_Position = aux + MVP * tMat *  vec4(cos(ang) * width1, -sin(ang) * l1, h, 1.0);
                    EmitVertex();

                }
                EndPrimitive();
    }

    void makePir(float width, float l,float h, int sides){
					vec4 gColorAux = gColor;
                    // Safe, GLfloats can represent small integers exactly
                    for (int i = 0; i <= sides; i++) {
                        // Angle between each side in radians
                        float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                        //float ang = (PI * 2.0) / vSides[0] * i;
                        //ang -= vTime[0];
                        //if(i%2==0)
                        //    gl_Position = aux * MVP;
                        //    EmitVertex();

                        ////gColor = vec4(sin(ang/15),sin(ang/15),sin(ang/15),1.0);
						gColor = gColor * vec4(vec3((sin(ang)+1)*0.4+0.3),1.0);
                        // Offset from center of point (0.3 to accomodate for aspect ratio)
                        vec4 offset = MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                        gl_Position = aux + offset;
                        EmitVertex();

                        offset = MVP * tMat * vec4(0.0, 0.0, h, 1.0);
                        gl_Position = aux + offset;
                        EmitVertex();


                    }
                    EndPrimitive();

					gColor = gColorAux;
                    // Safe, GLfloats can represent small integers exactly
                    for (int i = 0; i <= sides; i++) {
                        // Angle between each side in radians
                        float ang = ((PI * 2.0) / sides * i) + (PI / 4);
                        if(i%2==(sides%2)){
                            gl_Position = aux + MVP * tMat * vec4(0.0f,0.0f,-h,1.0f);
                            EmitVertex();
                        }

                        //gColor = vec4(sin(ang/7),sin(ang/7),sin(ang/7),1.0);
                        // Offset from center of point (0.3 to accomodate for aspect ratio)
                        vec4 offset = MVP * tMat * vec4(cos(ang) * width, -sin(ang) * l, -h, 1.0);
                        gl_Position = aux + offset;
                        EmitVertex();
                    }
                    EndPrimitive();
                    // Safe, GLfloats can represent small integers exactly
        }

    void makeSphere(float radius, int sides){
        float leap2 = (PI * 2.0) / float(sides);
        float leap = PI / float(sides);
        vec4 axis = vec4(0.0,1.0,0.0,1.0);
        vec4 camAx = vec4(cameraPos.xy,0.0,1.0);
        float c_angle = dot(camAx,axis)/(length(camAx)*length(axis));
        float angle = acos(c_angle);
        // Safe, GLfloats can represent small integers exactly
        for (int i = 0; i <= sides; i++) {
            float ang = leap * float(i);
            float ang1 = leap * float(i+1);
            // Angle between each side in radians
            for (int j = 0; j <= sides/2; j++)
            {
                float ang2 = leap2 * float(j) + angle;
                float ang3 = leap2 * float(j+1) + angle;
                //gColor = vec4((sin(ang)+1.0)/3,(sin(ang)+1.0)/3,(sin(ang)+1.0)/3,1.0);

                vec4 offset = MVP * tMat * vec4(sin(ang)*cos(ang2) * radius, sin(ang)*sin(ang2) * radius, cos(ang) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();
                     offset = MVP * tMat * vec4(sin(ang1)*cos(ang2) * radius, sin(ang1)*sin(ang2) * radius, cos(ang1) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();

            }
            EndPrimitive();
        }
        EndPrimitive();
    }

    void makeSphere1(float radius, int sides){
        float leap2 = (PI * 2.0) / sides;
        float leap = PI / sides;
        // Safe, GLfloats can represent small integers exactly
        for (int i = 0; i <=  sides /3; i++) {
            float ang = leap * i;
            float ang1 = leap * (i+1);
            // Angle between each side in radians
            for (int j = 0; j <= sides ; j++)
            {
                float ang2 = leap2 * j;
                float ang3 = leap2 * (j+1);
                //gColor = vec4(0.0,0.4,0.0,1.0);

                vec4 offset = MVP * tMat * vec4(sin(ang)*cos(ang2) * radius, sin(ang)*sin(ang2) * radius, cos(ang) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();
                     offset = MVP * tMat * vec4(sin(ang1)*cos(ang2) * radius, sin(ang1)*sin(ang2) * radius, cos(ang1) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();

            }
            EndPrimitive();
        }
        EndPrimitive();
    }

    void makeSphere2(float radius, int sides){
        float leap2 = (PI * 2.0) / sides;
        float leap = PI / sides;
        // Safe, GLfloats can represent small integers exactly
        for (int i = sides /3; i <= 2 *sides /3; i++) {
            float ang = leap * i;
            float ang1 = leap * (i+1);
            // Angle between each side in radians
            for (int j = 0; j <= sides; j++)
            {
                float ang2 = leap2 * j;
                float ang3 = leap2 * (j+1);
                //gColor = vec4(0.0,0.0,0.35,1.0);

                vec4 offset = MVP * tMat * vec4(sin(ang)*cos(ang2) * radius, sin(ang)*sin(ang2) * radius, cos(ang) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();
                     offset = MVP * tMat * vec4(sin(ang1)*cos(ang2) * radius, sin(ang1)*sin(ang2) * radius, cos(ang1) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();

            }
            EndPrimitive();
        }
        EndPrimitive();
    }

    void makeSphere3(float radius, int sides){
        float leap2 = (PI * 2.0) / sides;
        float leap = PI / sides;
        // Safe, GLfloats can represent small integers exactly
        for (int i = 2 *sides /3; i <= sides; i++) {
            float ang = leap * i;
            float ang1 = leap * (i+1);
            // Angle between each side in radians
            for (int j = 0; j <= sides; j++)
            {
                float ang2 = leap2 * j;
                float ang3 = leap2 * (j+1);
                //gColor = vec4(0.0,0.0,0.0,1.0);

                vec4 offset = MVP * tMat * vec4(sin(ang)*cos(ang2) * radius, sin(ang)*sin(ang2) * radius, cos(ang) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();
                     offset = MVP * tMat * vec4(sin(ang1)*cos(ang2) * radius, sin(ang1)*sin(ang2) * radius, cos(ang1) * radius, 1.0);
                gl_Position = aux + offset;
                EmitVertex();

            }
            EndPrimitive();
        }
        EndPrimitive();
    }


    float h(int i, float n_blocks){
        return vMat[0][2][2]*(n_blocks-float(i))/n_blocks;
    }

    float sumA(int n, float n_blocks){
        float ret = 0;
        for(int i = 1; i< n; i++){
            ret += 2.0f*h(i,n_blocks);
        }
        return ret;
    }

    float f(int n, float n_blocks){
        return vMat[0][2][2] + h(n,n_blocks) + sumA(n,n_blocks);
    }

    void building(float n_blocks,int sides){
        mat4 m;
        
        int random = int(rand((tMat * gl_in[0].gl_Position).xy)*5.0)+4;
        //gColor = vec4(topColor,topColor,topColor,1.0);
        
        makePrism(1.0, 1.0, 1.0, random);

        for (int i = 1; i < n_blocks; i++){

            m = mat4(vec4(1.0,0.0,0.0,0.0),vec4(0.0,1.0,0.0,0.0),vec4(0.0,0.0,1.0,0.0),vec4(0.0,0.0,f(i,5),1.0));

            //vMat[0][2][2]*((n_blocks-i+1)*(n_blocks+i)/(2*n_blocks))
            //gColor = vec4(topColor,topColor,topColor,1.0);
            //tMat *= m;
            //aux = aux + MVP * tMat * vec4(0.0,0.0,1.0,1.0);
            aux = MVP * m * tMat * gl_in[0].gl_Position;
            makePrism((6.0-i)/6.0, (6.0-i)/6.0, (5.0-i)/5.0, random);

        }
        if (rand((tMat * gl_in[0].gl_Position).xy)>0.8)
        {
            m = mat4(vec4(1.0,0.0,0.0,0.0),vec4(0.0,1.0,0.0,0.0),vec4(0.0,0.0,1.0,0.0),vec4(0.0,0.0,f(int(n_blocks),5),1.0));
            aux = MVP * m * tMat * gl_in[0].gl_Position;
            makePir((6.0-n_blocks)/6.0, (6.0-n_blocks)/6.0, abs((5.0-n_blocks)/5.0), random);
        }
    }

    float buildingBlocks(float h0){
        return h0 > 10? 4.0 : h0;
    }

    mat4 calcRotation(float angle, vec3 axis){
        mat4 aux_mat;
        float cosA = cos(angle);
        float sinA = sin(angle);
        aux_mat[0][0] = cosA                + axis.x * axis.x * (1-cosA);
        aux_mat[0][1] = axis.x * axis.y * (1-cosA) - sinA*axis.z;
        aux_mat[0][2] = sinA*axis.y + axis.x * axis.z * (1-cosA);

        aux_mat[1][0] = sinA*axis.z + axis.x*axis.y*(1-cosA);
        aux_mat[1][1] = cosA                + axis.y*axis.y*(1-cosA);
        aux_mat[1][2] = axis.z * axis.y * (1-cosA) - sinA*axis.x;


        aux_mat[2][0] = axis.x * axis.z * (1-cosA) - sinA*axis.y;
        aux_mat[2][1] = sinA*axis.x + axis.y*axis.z*(1-cosA);
        aux_mat[2][2] = cosA                + axis.z*axis.z*(1-cosA);

        aux_mat[0][3] = 0.0;
        aux_mat[1][3] = 0.0;
        aux_mat[2][3] = 0.0;
        aux_mat[3][3] = 1.0;
        aux_mat[3][2] = 0.0;
        aux_mat[3][1] = 0.0;
        aux_mat[3][0] = 0.0;

        return aux_mat;
    }
    /**
    * h - is the hight of the objects
    * divs - is the number of divisions
    */
  
    /*void makeSphere(float radius, int sides){
        float angle = (2*PI)/sides;
        int p2 = 360 / 2;
        int r2 = 180 / 2;
        for(int y = -r2; y < r2; ++y) {
            float cy = cos(y*angle);
            float cy1 = cos((y+1)*angle);
            float sy = sin(y*angle);
            float sy1 = sin((y+1)*angle);

            for(int i = -p2; i < p2; ++i) {
                float ci = cos(i*angle);
                float si = sin(i*angle);
                
                vec4 offset = MVP * vec4(radius * ci*cy, radius * si*cy, radius*sy, 0.0);
                gl_Position = aux + offset;
                EmitVertex();
                     offset = MVP * vec4(radius * ci*cy1, radius * si*cy1, radius*sy1, 0.0);
                gl_Position = aux + offset;
                EmitVertex();
            }
            EndPrimitive();
        }
        EndPrimitive();
    }*/






    bool notVisible(){

        vec4 rx = aux + MVP * tMat * vec4(1.0, 0.0, 0.0, 1.0);
        vec4 lx = aux + MVP * tMat * vec4(-1.0, 0.0, 0.0, 1.0);
        vec4 fy = aux + MVP * tMat * vec4(0.0, 1.0, 0.0, 1.0);
        vec4 by = aux + MVP * tMat * vec4(0.0, -1.0, 0.0, 1.0);
        vec4 uz = aux + MVP * tMat * vec4(0.0, 0.0, 1.0, 1.0);
        vec4 dz = aux + MVP * tMat * vec4(0.0, 0.0, -1.0, 1.0);

        // aux.x/aux.w>1 to check if the object is visible. changed to aux.x>aux.w to be faster by avoiding one division.
        //return aux.x>aux.w && aux.x<-aux.w && aux.y>aux.w && aux.y<-aux.w && aux.z>aux.w && aux.z<0 ;

        // each varieble is the point by the side of the current object's bounding box. r = right l = left


        return rx.x>rx.w && lx.x<-lx.w && dz.y>dz.w && uz.y<-uz.w && fy.z>fy.w && by.z<0;
    }

    mat4 cleanColor(mat4 mat){

        mat4 ret = mat;

        gColor = vec4(mat[0][3],mat[1][3],mat[2][3],1.0);

        ret[0][3]=0.0;
        ret[1][3]=0.0;
        ret[2][3]=0.0;

        return ret;
    }

    void main() {
       // calcRotation();
        tMat = cleanColor(vMat[0]);
        //tMat = vMat[0];
        if(notVisible()){
//            EndPrimitive();
            return;
        }

        //gColor = vec4(0.1,0.67,0.3,1.0);
        switch (vType[0]){
			case 0:
				makePoint(1.0,1.0,1.0);
			break;
            case 1:
				//box
                makePrism(1.0,1.0,1.0,4);
            break;

            case 2:
                makeSphere(1.0,calcSides(int(vSides[0])));
            break;

            case 3:
				//cylinder
                makePrism(1.0,1.0,1.0,calcSides(int(vSides[0])));
            break;
            case 4:
                makePir(1.0,1.0,1.0,int(vSides[0]));
            break;

            case 5:
                makeSphere1(1.0,calcSides(int(vSides[0])));
            break;

            case 6:
                makeSphere2(1.0,calcSides(int(vSides[0])));
            break;
            case 7:
                makeSphere3(1.0,calcSides(int(vSides[0])));
            break;

            case 8:
                building(vSides[0],4);
            break;

            case 9:
                makeTrunk(1.0,1.0,1.0,calcSides(int(vSides[0])), vRatio[0]);
				//tree(1.0,int(vSides[0]));
            break;

            case 10:
                makeRegSurface(1.0,1.0,int(vSides[0]));
            break;

			case 12:
                irregularPyramid3();
            break;

			case 14:
				makeTriangle();
				 break;
			case 15:
				makeExtrusion(int(vSides[0]),vScale[0]);
				break;
			default:
                 break;
        }
        

    }
);
