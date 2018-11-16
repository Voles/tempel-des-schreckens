// import $ from "jquery";
import { startGame } from "./StartGame";
// window.$ = window.jQuery = jQuery;

const api = {
    startGame: startGame,
    joinGame: null,
    getMyRooms: null,
    openRoom: null,
    getTableState: null,
};

window.api = api;

function createStartButton() {
    let startButton = document.createElement("button");
    startButton.innerText = "Start game";

    startButton.onclick = (event) => {
        startGame();
    };

    return startButton;
}

document.body.appendChild(createStartButton());