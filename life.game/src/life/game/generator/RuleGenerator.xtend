package life.game.generator

import life.game.gameDSL.Evolution
import life.game.gameDSL.Expr
import life.game.gameDSL.GoL
import life.game.gameDSL.Grid
import life.game.gameDSL.Initialization
import life.game.gameDSL.Point
import life.game.gameDSL.RULE
import org.eclipse.emf.common.util.EList

class RuleGenerator {
	
	def static toCode(GoL root)'''
	package GameOfLife;
		
	import java.awt.Point;
	import java.awt.Dimension;
	import java.util.ArrayList;

	public class RulesOfLife {
		public static void computeSurvivors(boolean[][] gameBoard, ArrayList<Point> survivingCells) {
	    	// Iterate through the array, follow game of life rules
	   		for (int i=1; i<gameBoard.length-1; i++) {
	        	for (int j=1; j<gameBoard[0].length-1; j++) {
	                int surrounding = 0;
	                if (gameBoard[i-1][j-1]) { surrounding++; }
	                if (gameBoard[i-1][j])   { surrounding++; }
	                if (gameBoard[i-1][j+1]) { surrounding++; }
	                if (gameBoard[i][j-1])   { surrounding++; }
	                if (gameBoard[i][j+1])   { surrounding++; }
	                if (gameBoard[i+1][j-1]) { surrounding++; }
	                if (gameBoard[i+1][j])   { surrounding++; }
	                if (gameBoard[i+1][j+1]) { surrounding++; }
	                
	                Point point = new Point(i-1,j-1);

	                if ((gameBoard[i][j])){
	               		«FOR evo : root.rules»«toCode(evo, RULE.LIVE)»«ENDFOR»

	                	«FOR evo : root.rules»«toCode(evo, RULE.DIE)»«ENDFOR»
	                }
	                else {
	                	«FOR evo : root.rules»«toCode(evo, RULE.AWAKEN)»«ENDFOR»
	                } 
	            }
	        }
	    }
	    
	    public static void initializePoints(ArrayList<Point> points) {
	    	«FOR init : root.init»«toCode(init)»«"\n"»«ENDFOR»
	    }
	    
	    public static Dimension setGrid() {
	    	return «toCode(root.grid)»;
	    }
	}
	'''
	
	def static CharSequence toCode(Initialization u) {
		if (u.getPoints().size() != 0) {
			return '''«FOR arg : u.getPoints()»«toCode(arg)»«ENDFOR»'''
		}
		else if (u.getPercentage() !== null) {
			return ""
		}
		else if (u.getRanges().size() != 0) {
			return ""
		}
	}
	
	def static CharSequence toCode(Point u) {
		return '''points.add(new Point(«u.x», «u.y»));'''
	}
	
	def static CharSequence toCode(Grid u) {
		if (u !== null){
			return '''new Dimension(«u.width», «u.height»)'''
		} 
		return '''null'''
	}
	
	def static CharSequence toCode(Evolution u, RULE target) {
		switch (u.rule) {
			case target: return '''if («toCode(u.exprs)») {«liveOrDie(target)»}'''
			default: return ""
		}
	}
	
	def static CharSequence liveOrDie(RULE target) {
		switch (target) {
			case RULE.DIE: return "survivingCells.remove(point);"
			default: return "survivingCells.add(point);"
		}
	}
	
	def static CharSequence toCode(EList<Expr> exprs) {
		return '''«FOR expr : exprs SEPARATOR " && "»surrounding «expr.op» «expr.number»«ENDFOR»'''
	}
}