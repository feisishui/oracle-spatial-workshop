/**
 * This class shows how a user constraint can be implemented
 * to guide the search for Oracle Network Network Data Model
 * The user constraint needs to implement the NetworkConstraint interface
 * which has two methods: requiresPathLinks and isSatisfied
 * The following example shows how link class can be used as a constraint
 * This constraint can be passed into any analysis functions
 * so that the results contain links with specific class for a given target class
 * Example:
 * Network network = readNetwork(...) ;// read in a network
 * NetworkConstraint constraint = new LinkClassConstraint(1); // create link class constraint
 * // search the shortest path that only contains links with specific type
 * Path path = NetworkManager.shortestPath(network,startNodeID,endNodeID,constraint);
 * Examples: road classes (link classes) and vehicles classes (target class), 
 *           canal classes(link classes) and boat classes (target classes) 
 * 
 */

package inmemory;

import oracle.spatial.network.*;

/**
 * The following link class constraint assumes that
 * 1. each link has a link class (stored as link_level:int in { 1,2,3 }) 
 * 2. for a given target class:int (in { 1,2,3 } ), the following must hold:
 *    target class 1 can only travel on link class 1
 *    target class 2 can travel on link class 1 and 2
 *    target class 3 can travel on link class 1,2 and 3  
 */
 
public class LinkClassConstraint implements NetworkConstraint {
    public LinkClassConstraint(int targetClass) { p_targetClass = targetClass; }
    int p_targetClass = -1; // target class of no restriction 
    public boolean requiresPathLinks() { return false ; } // path link info. not needed
    public boolean isSatisfied(AnalysisInfo info) { 
      if ( p_targetClass == -1 ) // no restriction
        return true ;
      Link link = info.getNextLink() ; // potential link candidate
      int linkLevel = link.getLinkLevel(); // store link class in link_level column
      if ( link != null && p_targetClass <= linkLevel )
        return true;
      else
        return false;
    }

};


