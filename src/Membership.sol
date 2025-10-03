// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import "openzeppelin/contracts/access/Ownable.sol";

contract ForestShareNFT is Ownable {
    enum Tier { Basic, Core }
    
    struct Member {
        address account;
        Tier tier;
        uint256 expiration;
        uint256 discountRate; // Basis points (100 = 1%)
    }

    mapping(address => Member) public members;
    mapping(Tier => uint256) public tierPrices;
    mapping(Tier => uint256) public tierDurations;
    mapping(Tier => uint256) public tierDiscounts;

    event MembershipCreated(address indexed member, Tier tier, uint256 expiration);
    event MembershipRenewed(address indexed member, uint256 newExpiration);
    event TierUpdated(Tier tier, uint256 newPrice, uint256 newDuration, uint256 newDiscount);

    error MembershipActive();
    error InvalidTier();
    error InsufficientPayment();
    error MembershipExpired();

    constructor() {
        _initializeTiers();
    }

    function _initializeTiers() private {
        tierPrices[Tier.Basic] = 0.1 ether;
        tierPrices[Tier.Core] = 0.3 ether;

        tierDurations[Tier.Basic] = 30 days;
        tierDurations[Tier.Core] = 90 days;

        tierDiscounts[Tier.Basic] = 500;  // 5%
        tierDiscounts[Tier.Core] = 1000; // 10%
    }

    function joinOrUpgrade(Tier tier) external payable {
        if (uint256(tier) > uint256(Tier.Core)) revert InvalidTier();
        if (msg.value < tierPrices[tier]) revert InsufficientPayment();
        
        Member storage member = members[msg.sender];
        if (member.expiration > block.timestamp) revert MembershipActive();

        member.account = msg.sender;
        member.tier = tier;
        member.expiration = block.timestamp + tierDurations[tier];
        member.discountRate = tierDiscounts[tier];

        emit MembershipCreated(msg.sender, tier, member.expiration);
    }

    function renewMembership() external payable {
        Member storage member = members[msg.sender];
        if (block.timestamp >= member.expiration) revert MembershipExpired();
        if (msg.value < tierPrices[member.tier]) revert InsufficientPayment();

        member.expiration += tierDurations[member.tier];
        emit MembershipRenewed(msg.sender, member.expiration);
    }

    function updateTierSettings(
        Tier tier,
        uint256 price,
        uint256 duration,
        uint256 discount
    ) external onlyOwner {
        tierPrices[tier] = price;
        tierDurations[tier] = duration;
        tierDiscounts[tier] = discount;
        emit TierUpdated(tier, price, duration, discount);
    }

    function hasActiveMembership(address account) public view returns (bool) {
        return members[account].expiration > block.timestamp;
    }

    function getDiscountRate(address account) public view returns (uint256) {
        return hasActiveMembership(account) ? members[account].discountRate : 0;
    }
}
