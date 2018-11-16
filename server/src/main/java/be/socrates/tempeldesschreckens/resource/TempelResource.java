package be.socrates.tempeldesschreckens.resource;

import be.socrates.tempeldesschreckens.domain.game.Game;
import be.socrates.tempeldesschreckens.domain.player.Player;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class TempelResource {

    private Game game;

    public TempelResource() {
    }

    @PostMapping("/start")
    public ResponseEntity start(@RequestBody StartInput playerCount) {
        game = Game.newGame(playerCount.getPlayerCount());
        return ResponseEntity.ok().build();
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
