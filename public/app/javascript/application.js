import { Application } from "./stimulus.js";
import EditController from "./controllers/edit_controller.js";

window.Stimulus = Application.start();
Stimulus.register("edit", EditController);
