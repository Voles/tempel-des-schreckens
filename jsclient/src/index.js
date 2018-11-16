import $ from "jquery";
// window.$ = window.jQuery = jQuery;

const api = {
    startGame: null,
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
        alert('hello world');
    };

    return startButton;
}

document.body.appendChild(createStartButton());