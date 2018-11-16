package be.socrates.tempeldesschreckens.domain.game;

import org.junit.Test;

import static be.socrates.tempeldesschreckens.domain.player.PlayerId.playerId;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class PlayerIdsTest {

    @Test
    public void constructor_CreatesPlayerIds1To8() {
        final PlayerIds playerIds = new PlayerIds();

        assertThat(playerIds.asList())
                .containsOnly(playerId(1),
                        playerId(2),
                        playerId(3),
                        playerId(4),
                        playerId(5),
                        playerId(6),
                        playerId(7),
                        playerId(8),
                        playerId(9),
                        playerId(10)
                        );
    }

    @Test
    public void next_FreshPlayerIds_ReturnsPlayer1() {
        final PlayerIds playerIds = new PlayerIds();

        assertThat(playerIds.next()).isEqualTo(playerId(1));
    }

    @Test
    public void next_ConsumedThreePlayerIds_ReturnsPlayer4() {
        final PlayerIds playerIds = new PlayerIds();

        assertThat(playerIds.next()).isEqualTo(playerId(1));
        assertThat(playerIds.next()).isEqualTo(playerId(2));
        assertThat(playerIds.next()).isEqualTo(playerId(3));
        assertThat(playerIds.next()).isEqualTo(playerId(4));
    }

    @Test
    public void next_8PlayersConsumed_ThrowsException() {
        final PlayerIds playerIds = new PlayerIds();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next();
        playerIds.next(); //returns 10th and last player

        assertThatThrownBy(playerIds::next).isInstanceOf(RuntimeException.class);
    }
}