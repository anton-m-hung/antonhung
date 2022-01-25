# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).
"""

import util

class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()


def tinyMazeSearch(problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    from game import Directions
    s = Directions.SOUTH
    w = Directions.WEST
    return  [s, s, w, s, w, w, s, w]

def depthFirstSearch(problem):
    """
    Search the deepest nodes in the search tree first.

    Your search algorithm needs to return a list of actions that reaches the
    goal. Make sure to implement a graph search algorithm.

    To get started, you might want to try some of these simple commands to
    understand the search problem that is being passed in:

    print("Start:", problem.getStartState())
    print("Is the start a goal?", problem.isGoalState(problem.getStartState()))
    print("Start's successors:", problem.getSuccessors(problem.getStartState()))
    """
    "*** YOUR CODE HERE ***"

    fringe = util.Stack()
    fringe.push(((problem.getStartState(),None,0), [(problem.getStartState(),None,0)]))
    # tuples of triples are pushed into the fringe. 1st tuple is a triple of the current state, 2nd tuple is a list of the triples for all the parents leading up the the current node

    path = [] # initialise path to be returned when the goal is reached
    explored = set() # keeps track of which states have been explored
    
    while not fringe.isEmpty():
        node = fringe.pop()
        
        if problem.isGoalState(node[0][0]):
            for direction in node[1]: # node[1] is the list of triples for all the parents leading to the goal (state,direction,cost)
                if direction[1] is not None:
                    path.append(direction[1]) # append only the direction to the result
            return(path)
        
        if node[0][0] not in explored:
            explored.add(node[0][0])
            successors = problem.getSuccessors(node[0][0])
            
            for successor in successors:
                parentPath = node[1][:] # placeholder variable to keep track of the parents leading up to the successor
                parentPath.append(successor) # add the successor itself to the path
                fringe.push((successor, parentPath)) # push the successor triple along with the entire path into fringe

    return util.raiseNotDefined()

def breadthFirstSearch(problem):
    """Search the shallowest nodes in the search tree first."""
    "*** YOUR CODE HERE ***"
    
    fringe = util.Queue()
    fringe.push(((problem.getStartState(),None,0), [(problem.getStartState(),None,0)]))

    path = []
    explored = set()
    
    while not fringe.isEmpty():
        node = fringe.pop()
        
        if problem.isGoalState(node[0][0]):
            for direction in node[1]:
                if direction[1] is not None:
                    path.append(direction[1])
            return(path)
        
        if node[0][0] not in explored:
            explored.add(node[0][0])
            successors = problem.getSuccessors(node[0][0])
            
            for successor in successors:
                parentPath = node[1][:]
                parentPath.append(successor)
                fringe.push((successor, parentPath))

    return util.raiseNotDefined()

def uniformCostSearch(problem):
    """Search the node of least total cost first."""
    "*** YOUR CODE HERE ***"
    
    fringe = util.PriorityQueue()
    fringe.push((((problem.getStartState(),None,0), [])), 0) # 2nd triple just holds the actions taken to get to the current state

    path = []
    explored = set()
    
    while not fringe.isEmpty():
        node = fringe.pop()
        
        if problem.isGoalState(node[0][0]):
            for direction in node[1]:
                path.append(direction)
            return(path)
        
        if node[0][0] not in explored:
            explored.add(node[0][0])
            successors = problem.getSuccessors(node[0][0])
            
            for successor in successors:
                parentPath = node[1][:]
                parentPath.append(successor[1])
                
                fringe.update(((successor, parentPath)), problem.getCostOfActions(parentPath)) # along with the same information as dfs and bfs, push also the costOfAction into the fringe

    return util.raiseNotDefined()

def nullHeuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0

def aStarSearch(problem, heuristic=nullHeuristic):
    """Search the node that has the lowest combined cost and heuristic first."""
    "*** YOUR CODE HERE ***"
    import searchAgents
    
    fringe = util.PriorityQueue()
    fringe.push((((problem.getStartState(),None,0), [])), 0)

    path = []
    explored = set()
    
    while not fringe.isEmpty():
        node = fringe.pop()
        
        if problem.isGoalState(node[0][0]):
            for direction in node[1]:
                if direction is not None:
                    path.append(direction)
            return(path)
        
        if node[0][0] not in explored:
            explored.add(node[0][0])
            successors = problem.getSuccessors(node[0][0])
            
            for successor in successors:
                parentPath = node[1][:]
                parentPath.append(successor[1])
                
                Heuristic = heuristic(successor[0],problem)
                combinedCost = Heuristic + problem.getCostOfActions(parentPath) # adds the heuristic and path cost to obtain an estimation of how far you are from the goal

                fringe.update(((successor, parentPath)), combinedCost)

    return util.raiseNotDefined()
    

# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
