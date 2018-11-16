import $ from "jquery";

export function startGame() {
    console.log('Starting Game... woop');

    let url = "http://localhost:3000/start";

    function success() {
        alert("Succesfully started a game");
    }

    $.ajax({
        type: "POST",
        url: url,
        data: {
            playerCount: 4
        },
        success: success
    });
}