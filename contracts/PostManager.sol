// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PostManager {
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 likesCount;
        bool exists;
    }

    address public owner;
    uint256 private nextPostId;
    
    mapping(uint256 => Post) public posts;
    mapping(uint256 => mapping(address => bool)) public hasLiked;
    uint256[] public activePostIds;

    event PostCreated(uint256 indexed postId, address indexed author, string content);
    event PostDeleted(uint256 indexed postId, address indexed deletedBy);
    event PostLiked(uint256 indexed postId, address indexed user, bool liked);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPost(string memory _content) external {
        require(bytes(_content).length > 0, "Content cannot be empty");
        uint256 postId = nextPostId++;
        
        posts[postId] = Post({
            id: postId,
            author: msg.sender,
            content: _content,
            likesCount: 0,
            exists: true
        });

        activePostIds.push(postId);
        emit PostCreated(postId, msg.sender, _content);
    }

    function deletePost(uint256 _postId) external {
        require(posts[_postId].exists, "Post does not exist");
        require(
            msg.sender == posts[_postId].author || msg.sender == owner, 
            "Not authorized to delete this post"
        );

        delete posts[_postId];
        _removeActivePostId(_postId);
        emit PostDeleted(_postId, msg.sender);
    }

    function deleteAllPosts() external onlyOwner {
        for (uint256 i = 0; i < activePostIds.length; i++) {
            delete posts[activePostIds[i]];
        }
        delete activePostIds;
    }

    function toggleLike(uint256 _postId) external {
        require(posts[_postId].exists, "Post does not exist");

        if (hasLiked[_postId][msg.sender]) {
            hasLiked[_postId][msg.sender] = false;
            posts[_postId].likesCount -= 1;
            emit PostLiked(_postId, msg.sender, false);
        } else {
            hasLiked[_postId][msg.sender] = true;
            posts[_postId].likesCount += 1;
            emit PostLiked(_postId, msg.sender, true);
        }
    }

    function _removeActivePostId(uint256 _postId) internal {
        for (uint256 i = 0; i < activePostIds.length; i++) {
            if (activePostIds[i] == _postId) {
                activePostIds[i] = activePostIds[activePostIds.length - 1];
                activePostIds.pop();
                break;
            }
        }
    }
}