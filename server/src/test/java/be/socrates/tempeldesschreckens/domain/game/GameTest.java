package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.Room;
import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class GameTest {

    @Test
    public void newGame_With3Players_ShouldHave8EmptyRooms_And5Treasures_And2Traps() {
        Game game = Game.newGame(3);

        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.EMPTY)).hasSize(8);
        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.TREASURE)).hasSize(5);
        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.TRAP)).hasSize(2);
    }

    @Test
    public void newGame_WithMoreThan10PlayerCount_ThrowsException() {
        assertThatThrownBy(() -> Game.newGame(11))
                .isInstanceOf(IllegalArgumentException.class);
    }
}