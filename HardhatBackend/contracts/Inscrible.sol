//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

contract Inscrible {
    
    //USER STRUCT
    struct User{
        string username;
        friend[] followersList;
        friend[] followingsList;
        //chawala
        Post [] myPosts;
        // string profilePic; do add later
    }

    struct AllUserStruck{
        string username;
        address accountAddress;
    }
    
   struct friend{
        address pubkey;
        string name;
    }

      //CONTAINING ALL THE POSTS UPLOADED BY USERS
    struct Post{
        string createrName;
        address payable userAddress;
        string imageHash;
        string caption;
        string imageText;
        uint256  tipAmount;
        uint256 id;
        uint likeCount;
        string [] likedByUser;
    }

    AllUserStruck[] AllUsers;
    //POST COUNT
    uint postCount = 0;
    
    mapping(address=>Post[]) AllPostsMapping;
    mapping(address=>User) userList;
    // User [] allRegisteredUsers;
    mapping(address=>Post[]) singleUserPostList;
    Post [] allposts;


    //FUNCTIONS----------------------------

    //CHECK IS A USER HAS AN ACCOUNT
    function checkUser(address key) public view returns(bool){
        if(AllUsers.length > 0)
        return bytes(userList[key].username).length > 0;
        else{
            return false;
        }
    }

    //GET USER NAME
    function getUsername(address key) public view returns(string memory){
        return userList[key].username;
    }

    //CREATE ACCOUNT
    function createAccount(string calldata _username) external {
        require(checkUser(msg.sender) == false, "User alredy has an account!");
        require(bytes(_username).length > 0, "User name should not be empty!");

        userList[msg.sender].username = _username;
        AllUsers.push(AllUserStruck(_username, msg.sender));
    }
    //addFriend Function
    //this function will add the msg.sender(follower) in the followersList of the person whom he is following
    //following_key is the address of the person whom he is following
     function addFriend(address following_key) external{
        //msg.sender is actually the follower
        require(checkUser(msg.sender), "Create an account first");
        require(checkUser(following_key), "User is not registered!");
        require(msg.sender != following_key, "Users cannot add themeselves as friends");
        require(checkAlreadyFriends(msg.sender,following_key)== false, "These users are already friends");

         //_addFriend(msg.sender, friend_key, name);
          _addFriend(following_key, msg.sender, userList[msg.sender].username);

         for(uint256 i=0;i<userList[following_key].myPosts.length;i++)
         {
            singleUserPostList[msg.sender].push(userList[following_key].myPosts[i]);
         }
    }
    //checkAlreadyFriend
    //will check if me(msg.sender means follower) exist in the followerList of the perosn whom he is following
    function checkAlreadyFriends(address me,address following_key) public view returns (bool){

        for(uint256 i = 0; i < userList[following_key].followersList.length; i++){
            
            if(userList[following_key].followersList[i].pubkey == me) return true;
        }
        return false;
    }
    //_AddFriend
    function _addFriend(address following_key, address me, string memory name) internal{
       friend memory newFollower = friend(me, name);
        userList[following_key].followersList.push(newFollower);

        friend memory newFollowing = friend(following_key, userList[following_key].username);
        userList[me].followingsList.push(newFollowing);
    }


    function removeFriend(address followingAddress) public {

        //Removing follower(msg.sender) from the followerList of our following(followingAddress)
        uint256 followerIndex;
        bool found = false;

        // Find the index of the friend in the array
        for (uint256 i = 0; i < userList[followingAddress].followersList.length; i++) {
            if (userList[followingAddress].followersList[i].pubkey == msg.sender) {
                followerIndex = i;
                found = true;
                break;
            }
        }
        // If the friend is found, remove it
        if (found) {
            // Replace the element at friendIndex with the last element
            userList[followingAddress].followersList[followerIndex] = userList[followingAddress].followersList[userList[followingAddress].followersList.length - 1];
            // Reduce the size of the array by one
            userList[followingAddress].followersList.pop();
       }

        //------------------------------------------------------------------------------
        //Removing followingAddress from our followingList
        //-------------------------------------------------------------------------------

        uint256 followingIndex;
        bool foundFollowing = false;

        // Find the index of the friend in the array
        for (uint256 i = 0; i < userList[msg.sender].followingsList.length; i++) {
            if (userList[msg.sender].followingsList[i].pubkey == followingAddress) {
                followingIndex = i;
                foundFollowing = true;
                break;
            }
        }
        // If the friend is found, remove it
        if (foundFollowing) {
            // Replace the element at friendIndex with the last element
            uint256 lengthOfFollowingList  = userList[msg.sender].followingsList.length;
            userList[msg.sender].followingsList[followingIndex] = userList[msg.sender].followingsList[lengthOfFollowingList - 1];
            // Reduce the size of the array by one
            userList[msg.sender].followingsList.pop();
       }


    }

    //GETMY FRIEND
    function getMyFollowersList(address user) external view returns(friend [] memory){
        return userList[user].followersList;
    }
    function getMyFollowingsList(address user) external view returns(friend[] memory){
        return userList[user].followingsList;
    }

    //TO POST IMAGES TO BLOCKCHAIN
    function addPostImage(string memory _imgHash, string memory desc, string memory imgText) public 
    {   
        require(checkUser(msg.sender), "User not registered!");
        require(bytes(_imgHash).length > 0);
        postCount=postCount+1;
        Post memory newPost = Post({
            createrName: userList[msg.sender].username,
            userAddress: payable(msg.sender),
            imageHash: _imgHash,
            caption: desc,
            imageText: imgText,
            tipAmount:0,
            id:postCount,
            likeCount:0,
            likedByUser : new string[](0)         
        });
            
        // for(uint256 i = 0; i < userList[msg.sender].followersList.length; i++){
        //     singleUserPostList[userList[msg.sender].followersList[i]].push(newPost);
        //  } 
        userList[msg.sender].myPosts.push(newPost);
        // singleUserPostList[msg.sender].push(newPost);
        allposts.push(newPost);
        //singleUserPostList[msg.sender].push(newPost);
        
        
        //AllPostsMapping[msg.sender].push(newPost);
        // _AllFriendPosts();
    }

    function getAllPosts() public view returns(Post [] memory){
        return allposts;
    }
    
   function getAllAppUser() public view returns(AllUserStruck[] memory){
        return AllUsers;
    }

    // function getSingleUserPost(address key) public view returns(Post [] memory) {
    //     if (singleUserPostList[key].length > 0) {
    //         return singleUserPostList[key];
    //     } else {
    //         return new Post[](0);
    //     }
    // }

    // function getSingleUserLatestPost(address key) public view returns(Post memory){
        
    //         return  singleUserPostList[key][singleUserPostList[key].length-1]; 
        
    // } 

    //Arishsssssssss
    function tipPostOwner(uint256 _id) external payable {
        // Make sure the id is valid
        require(_id > 0 && _id <= postCount, "Invalid post id");
        require(allposts[_id-1].userAddress != msg.sender, "Cannot tip your own post");
        // Fetch the post
        
        address payable user = allposts[_id-1].userAddress;
        // Pay the author by sending them Ether
        user.transfer(msg.value);
        // Increment the tip amount
        allposts[_id-1].tipAmount += msg.value;

            for(uint256 i=0; i < userList[user].myPosts.length;i++){
                if(userList[user].myPosts[i].id == _id){
                    userList[user].myPosts[i].tipAmount += msg.value;
                    break;
                }
            }
        
    }
    
    struct LikedExsistence{
        uint index;
        bool exists;
    }

    function checkIfLikedByExists(string[] memory likedBy, string memory username) public pure returns (LikedExsistence memory) 
    {
        uint i = 0;
        for (i = 0; i < likedBy.length; i++) {
           if (keccak256(bytes(likedBy[i])) == keccak256(bytes(username))) {
               return LikedExsistence(i,true);

               //break;
            }
        }
        return LikedExsistence(0,false);
    }
    //increment like Count
   function incrementLike(uint  post_id) external returns (bool)
   { 
     require(post_id > 0 && post_id <= postCount);
     //require(allposts[post_id-1].userAddress != msg.sender, "Cannot like your own post");
     //require(!checkIfLikedByExists(allposts[post_id-1].likedByUser,userList[msg.sender].username),"You have already liked it");
        uint postIndex = 0;
        LikedExsistence memory liked = checkIfLikedByExists(allposts[post_id-1].likedByUser,userList[msg.sender].username);
        if (liked.exists == false){
            // Increment the like post
            //allposts[post_id-1].likeCount++;
            allposts[post_id-1].likeCount++;

            for(uint256 i=0; i < userList[allposts[post_id-1].userAddress].myPosts.length;i++){
                if(userList[allposts[post_id-1].userAddress].myPosts[i].id == post_id){
                    userList[allposts[post_id-1].userAddress].myPosts[i].likeCount++;
                    postIndex = i;
                    break;
                }
            }
            // allposts[post_id-1].likedByUser[allposts[post_id-1].likeCount]=userList[msg.sender].name;
            allposts[post_id-1].likedByUser.push(userList[msg.sender].username);
            return true;
        }
        else{
            
            //decrementing the likeCount
            userList[allposts[post_id-1].userAddress].myPosts[postIndex].likeCount--;
            //putting the user on the end of the array so that it can be popped frfom the likedByUser array 
            string memory temp = allposts[post_id-1].likedByUser[liked.index];
            allposts[post_id-1].likedByUser[liked.index] = allposts[post_id-1].likedByUser[allposts[post_id-1].likedByUser.length - 1];
            allposts[post_id-1].likedByUser[allposts[post_id-1].likedByUser.length - 1] = temp;

            allposts[post_id-1].likedByUser.pop();
            return false;
        }
   }

    function getOneUserPosts(address userAddress) public view returns(Post [] memory){
        return userList[userAddress].myPosts;
        
    }
    function getTipAmountByPostId(uint post_id) public view returns(uint256){
        return allposts[post_id-1].tipAmount;
    }
    
    receive() external payable {}
}
