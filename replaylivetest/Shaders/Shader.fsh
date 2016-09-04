//
//  Shader.fsh
//  replaylivetest
//
//  Created by zl on 16/8/24.
//  Copyright © 2016年 wang. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
