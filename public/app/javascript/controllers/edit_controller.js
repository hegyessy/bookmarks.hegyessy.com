import { Controller } from "../stimulus.js";

export default class extends Controller {
  static targets = ["bookmarks"];
  
  toggle() {
    this.bookmarksTarget.classList.toggle("edit");
  }
}
