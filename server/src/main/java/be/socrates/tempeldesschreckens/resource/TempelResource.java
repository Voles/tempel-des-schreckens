package be.socrates.tempeldesschreckens.resource;

import be.socrates.tempeldesschreckens.domain.game.Game;
import be.socrates.tempeldesschreckens.domain.game.GameId;
import be.socrates.tempeldesschreckens.domain.player.Player;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TempelResource {

    private final Game game;

    public TempelResource() {
        this.game = new Game();
    }

    @PostMapping("/start/{playerCount}")
    public ResponseEntity<GameId> start(@PathVariable("playerCount") Integer playerCount) {
        return ResponseEntity.ok(game.newGame(playerCount));
    }

    @PostMapping("/join/{playerName}")
    public ResponseEntity<Player> join(@PathVariable("secretToken") String playerName) {
        return ResponseEntity.ok(game.newPlayer(playerName));
    }

    @PostMapping("/my-rooms/{secretToken}")
    public ResponseEntity myRooms(@PathVariable("secretToken") String playerName) {
        return null;
    }

    @PostMapping("/open/{secretToken}")
    public ResponseEntity open(@PathVariable("secretToken") String playerName) {
        return null;
    }

    @PostMapping("/table/{secretToken}")
    public ResponseEntity table(@PathVariable("secretToken") String playerName) {
        return null;
    }

}
