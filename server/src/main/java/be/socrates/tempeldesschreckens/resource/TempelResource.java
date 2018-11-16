package be.socrates.tempeldesschreckens.resource;

import be.socrates.tempeldesschreckens.domain.game.Game;
import be.socrates.tempeldesschreckens.domain.game.GameId;
import be.socrates.tempeldesschreckens.domain.player.Player;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class TempelResource {

    private final Game game;

    public TempelResource() {
        this.game = new Game();
    }

    @PostMapping("/start")
    public ResponseEntity<GameId> start(@RequestBody StartInput playerCount) {
        return ResponseEntity.ok(game.newGame(playerCount.getPlayerCount()));
    }

    @PostMapping("/join")
    public ResponseEntity<Player> join(@RequestBody Identification identification) {
        return ResponseEntity.ok(game.newPlayer(identification.getSecretToken()));
    }

    @GetMapping("/my-rooms/{secretToken}")
    public ResponseEntity myRooms(@RequestParam("secretToken") String secretToken) {
        return null;
    }

    @GetMapping("/table")
    public ResponseEntity table() {
        return null;
    }

    @PostMapping("/open")
    public ResponseEntity open(@RequestParam OpenInput openInput) {
        return null;
    }

}
