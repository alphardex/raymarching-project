import * as kokomi from "kokomi.js";
import * as THREE from "three";

import TestObject from "./TestObject";
import RaymarchingScene from "./RaymarchingScene";

export default class World extends kokomi.Component {
  constructor(base) {
    super(base);

    this.base.am.on("ready", () => {
      this.rs = new RaymarchingScene(this.base);
      this.rs.addExisting();
      document.querySelector(".loader-screen")?.classList.add("hollow");
    });
  }
}
