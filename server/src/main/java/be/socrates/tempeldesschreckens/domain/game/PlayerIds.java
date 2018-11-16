package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.player.PlayerId;

import java.util.Arrays;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedDeque;

import static be.socrates.tempeldesschreckens.domain.player.PlayerId.playerId;

class PlayerIds {
    private Queue<PlayerId> availableIds;

    PlayerIds() {
        availableIds = new ConcurrentLinkedDeque<>();
        this.availableIds.addAll(Arrays.asList(playerId(1),
                playerId(2),
                playerId(3),
                playerId(4),
                playerId(5),
                playerId(6),
                playerId(7),
                playerId(8)));
    }

    Queue<PlayerId> asList() {
        return availableIds;
    }

    PlayerId next() {
        return Optional.ofNullable(availableIds.poll()).orElseThrow(() -> new RuntimeException("Game is full"));
    }

}
