import * as kokomi from "kokomi.js";

import raymarchingSceneFragmentShader from "../Shaders/RaymarchingScene/frag.glsl";

export default class RaymarchingScene extends kokomi.Component {
  constructor(base) {
    super(base);

    this.quad = new kokomi.ScreenQuad(this.base, {
      fragmentShader: raymarchingSceneFragmentShader,
      shadertoyMode: true,
    });
  }
  addExisting() {
    this.quad.addExisting();
  }
}
