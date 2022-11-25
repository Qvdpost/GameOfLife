package life.game.generator

import life.game.gameDSL.COMPLEX
import life.game.gameDSL.Evolution
import life.game.gameDSL.Expr
import life.game.gameDSL.GoL
import life.game.gameDSL.Grid
import life.game.gameDSL.Initialization
import life.game.gameDSL.LOGICALOPERATOR
import life.game.gameDSL.Pattern
import life.game.gameDSL.Percentage
import life.game.gameDSL.Point
import life.game.gameDSL.RULE
import life.game.gameDSL.Range
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
	               		«FOR evo : root.rules.list»«toCode(evo, RULE.LIVE)»«ENDFOR»

	                	«FOR evo : root.rules.list»«toCode(evo, RULE.DIE)»«ENDFOR»
	                }
	                else {
	                	«FOR evo : root.rules.list»«toCode(evo, RULE.AWAKEN)»«ENDFOR»
	                } 
	            }
	        }
	    }
	    
	    public static void initializePoints(ArrayList<Point> points) {
	    	«FOR init : root.init.list SEPARATOR "\n"»«IF init.getPoints().size() != 0»«FOR point : init.getPoints() SEPARATOR "\n"»«toCode(point)»«ENDFOR»«ENDIF»«ENDFOR»
	    	«FOR init : root.init.list SEPARATOR "\n"»«IF init.getRanges().size() != 0»«FOR point : init.getRanges() SEPARATOR "\n"»«toCode(point)»«ENDFOR»«ENDIF»«ENDFOR»
	    	«FOR init : root.init.list SEPARATOR "\n"»«IF init.getPatterns().size() != 0»«FOR pattern : init.getPatterns() SEPARATOR "\n"»«toCode(pattern)»«ENDFOR»«ENDIF»«ENDFOR»
	    }
	    
	    public static int initializePercentage() {
	    	«IF initPercent(root.init.list).length() != 0»«initPercent(root.init.list)»«ELSE»return 0;«ENDIF»
	    }
	    
	    public static Dimension setGrid() {
	    	return «toCode(root.grid)»;
	    }
	}
	'''
	
	def static CharSequence initPercent(EList<Initialization> init) {
		return '''«FOR u : init»«IF u.getPercentage() !== null»return «toCode(u.getPercentage())»«ENDIF»«ENDFOR»'''
	}
	
	def static CharSequence toCode(Point u) {
		return '''points.add(new Point(«u.x», «u.y»));'''
	}
	
	def static CharSequence toCode(Percentage u) {
		return '''«u.number»;'''
	}
	
	def static CharSequence toCode(Range u) {
		return '''«FOR x : u.p1.x ..< u.p2.x SEPARATOR "\n"»«FOR y: u.p1.y ..< u.p2.y SEPARATOR "\n"»points.add(new Point(«x», «y»));«ENDFOR»«ENDFOR»'''
	}
	
	def static CharSequence toCode(Pattern p) {
		switch(p.pattern) {
			case COMPLEX.BLINKER: return '''points.add(new Point(«p.start.x», «p.start.y»));«"\n"»points.add(new Point(«p.start.x», «p.start.y+1»));«"\n"»points.add(new Point(«p.start.x», «p.start.y+2»));«"\n"»'''
			case COMPLEX.BLOCK: return '''points.add(new Point(«p.start.x», «p.start.y»));«"\n"»points.add(new Point(«p.start.x+1», «p.start.y»));«"\n"»points.add(new Point(«p.start.x», «p.start.y+1»));«"\n"»points.add(new Point(«p.start.x+1», «p.start.y+1»));«"\n"»'''
			case COMPLEX.GLIDER: return '''points.add(new Point(«p.start.x», «p.start.y+1»));«"\n"»points.add(new Point(«p.start.x+1», «p.start.y+2»));«"\n"»points.add(new Point(«p.start.x+2», «p.start.y+2»));«"\n"»points.add(new Point(«p.start.x+2», «p.start.y+1»));«"\n"»points.add(new Point(«p.start.x+2», «p.start.y»));«"\n"»'''
		}
	}
	
	def static CharSequence toCode(Grid u) {
		if (u !== null){
			return '''new Dimension(«u.width», «u.height»)'''
		} 
		return '''null'''
	}
	
	def static CharSequence toCode(Evolution u, RULE target) {
		switch (u.rule) {
			case target: return '''if («toCode(u)») {«liveOrDie(target)»}'''
			default: return ""
		}
	}
	
	def static CharSequence toCode(Evolution u) {
		if (u.name == "Percentage:") {
			return '''Math.random()*100 < «u.number.number»'''
		}
		if (u.name == "Neighbors:") {
			return toCode(u.expr)
		}
	}
	
	def static CharSequence liveOrDie(RULE target) {
		switch (target) {
			case RULE.DIE: return "survivingCells.remove(point);"
			default: return "survivingCells.add(point);"
		}
	}
	
	def static CharSequence toCode(EList<Expr> exprs) {
		return '''«FOR expr : exprs SEPARATOR " || "»(«toCode(expr)»)«ENDFOR»'''
	}
	
	def static CharSequence toCode(Expr expr) {
		return '''surrounding «expr.op» «expr.number»«IF expr.other !== null»«toCode(expr.getLogOp())»«toCode(expr.other)»«ENDIF»'''
	}
	
	def static CharSequence toCode(LOGICALOPERATOR op) {
		switch (op) {
			case LOGICALOPERATOR.AND: return " && "
			case LOGICALOPERATOR.OR: return " || "
			default: return ""
		}
	}
}