/*
 * generated by Xtext 2.28.0
 */
package life.game.ide

import com.google.inject.Guice
import life.game.GameDSLRuntimeModule
import life.game.GameDSLStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class GameDSLIdeSetup extends GameDSLStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new GameDSLRuntimeModule, new GameDSLIdeModule))
	}
	
}
