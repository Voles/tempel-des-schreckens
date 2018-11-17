package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.player.PlayerId;

import java.util.Arrays;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedDeque;

import static be.socrates.tempeldesschreckens.domain.player.PlayerId.playerId;

class PlayerIds {
    private Queue<PlayerId> availableIds;

    PlayerIds(Integer playerCount) {
        availableIds = new ConcurrentLinkedDeque<>();
        for (int i = 1;i<=playerCount;i++) {
            this.availableIds.add(playerId(i));
        }
    }

    Queue<PlayerId> asList() {
        return availableIds;
    }

    PlayerId next() {
        return Optional.ofNullable(availableIds.poll()).orElseThrow(() -> new RuntimeException("Game is full"));
    }

}
