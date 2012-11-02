module RelationshipsHelper
  #Returns whether the given user is friends with the current user
  def friends?(user)
    relationship = get_relationship(current_user, user)
    return relationship.length > 0 && relationship[0][:friend_status] == 'FRIENDS'
  end
  
  #Returns whether the logged in user has already tried to initiate friendship on 
  def my_pending?(user)
    relationship = get_one_sided(current_user, user)
    return relationship.length > 0 && relationship[0][:friend_status] == 'PENDING'
  end
  
  def other_pending?(user)
    relationship = get_one_sided(user, current_user)
    return relationship.length > 0 && relationship[0][:friend_status] == 'PENDING'
  end
  
  #Returns whether the given user is not friends with the current user
  def not_friends?(user)
    relationship = get_relationship(current_user, user)
    return relationship.length == 0
  end
  
  private
  
  #Retrieves any relationship between the two users
  def get_relationship(user1, user2)
    return Relationship.where("follower_id = :follower_id and followed_id = :followed_id or follower_id = :followed_id and followed_id = :follower_id", {followed_id: user1.id, follower_id: user2.id})
  end
  
  #Retrieves the friendship starting from user1. This means the people that user1 has initiated friendship with
  def get_one_sided(user1, user2)
    return Relationship.where("follower_id = :follower_id and followed_id = :followed_id", {follower_id: user1.id, followed_id: user2.id})
  end
  
end