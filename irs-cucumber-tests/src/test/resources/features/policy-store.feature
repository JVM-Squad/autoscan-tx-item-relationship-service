# https://github.com/eclipse-tractusx/item-relationship-service/issues/518
Feature: Policy Store

  Background:
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # TODO (mfischer): #518 How do we reuse these from E2ETestStepDefinitions (step names must be unique!)
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Given the IRS URL "https://irs.dev.demo.catena-x.net/" -- policystore
    And the admin user api key -- policystore



  Scenario: Register and get all policies

    Given no policies with prefix "integration-test-policy-" exist

    When a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"
    # 'POST policies' only supports one BPN, therefore if we want to associate a policy with multiple BPNs
    # we first need to create it via POST for the first BPN
    # and then add it via 'UPDATE policies' to all BPNs to which it should be associated
    # (note that this also update the validUntil).
    And a policy with policyId "integration-test-policy-2222" is registered for BPN "BPNL1234567890AB" and validUntil "2222-11-11T11:11:11.111Z"
    And I add policyId "integration-test-policy-2222" to given BPNs using validUntil "2222-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890CD |
    And a policy with policyId "integration-test-policy-3333" is registered for BPN "BPNL1234567890CD" and validUntil "3333-11-11T11:11:11.111Z"
    And a policy with policyId "integration-test-policy-4444" is registered for BPN "BPNL1234567890CD" and validUntil "4444-11-11T11:11:11.111Z"
    And I fetch all policies

    Then the BPNs should be associated with policies as follows:
      | BPN              | policyId                     |
      | BPNL1234567890AB | integration-test-policy-1111 |
      | BPNL1234567890AB | integration-test-policy-2222 |
      | BPNL1234567890CD | integration-test-policy-2222 |
      | BPNL1234567890CD | integration-test-policy-3333 |
      | BPNL1234567890CD | integration-test-policy-4444 |


  Scenario: Update a policy validUntil date

    Given no policies with prefix "integration-test-policy-" exist
    Given a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"

    When I update policy "integration-test-policy-1111", BPN "BPNL1234567890AB", validUntil "1112-11-11T11:11:11.111Z"
    And I fetch all policies

    Then the BPN "BPNL1234567890AB" should have a policy with policyId "integration-test-policy-1111" and validUntil "1112-11-11T11:11:11.111Z"



  Scenario: Update a policy validUntil date for a policy that is associated to multiple BPNs

    Given no policies with prefix "integration-test-policy-" exist

    Given a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"
    # 'POST policies' only supports one BPN, therefore if we want to associate a policy with multiple BPNs
    # we first need to create it via POST for the first BPN
    # and then add it via 'UPDATE policies' to all BPNs to which it should be associated
    # (note that this also update the validUntil).
    And a policy with policyId "integration-test-policy-2222" is registered for BPN "BPNL1234567890AB" and validUntil "2222-11-11T11:11:11.111Z"
    And I add policyId "integration-test-policy-2222" to given BPNs using validUntil "2222-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890CD |
    And a policy with policyId "integration-test-policy-3333" is registered for BPN "BPNL1234567890CD" and validUntil "3333-11-11T11:11:11.111Z"
    And a policy with policyId "integration-test-policy-4444" is registered for BPN "BPNL1234567890CD" and validUntil "4444-11-11T11:11:11.111Z"
    And I fetch all policies
    And the BPN "BPNL1234567890AB" should have a policy with policyId "integration-test-policy-1111" and validUntil "1111-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890AB" should have a policy with policyId "integration-test-policy-2222" and validUntil "2222-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-2222" and validUntil "2222-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-3333" and validUntil "3333-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-4444" and validUntil "4444-11-11T11:11:11.111Z"

    When I update policy with policyId "integration-test-policy-2222" and given BPNs using validUntil "2223-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890CD |
    And I fetch all policies

    Then the BPN "BPNL1234567890AB" should have a policy with policyId "integration-test-policy-1111" and validUntil "1111-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890AB" should have a policy with policyId "integration-test-policy-2222" and validUntil "2223-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-2222" and validUntil "2223-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-3333" and validUntil "3333-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-4444" and validUntil "4444-11-11T11:11:11.111Z"



  Scenario: Add BPN to policy

    Given no policies with prefix "integration-test-policy-" exist
    Given a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"
    And a policy with policyId "integration-test-policy-2222" is registered for BPN "BPNL1234567890CD" and validUntil "2222-11-11T11:11:11.111Z"

    When I update policy "integration-test-policy-1111", BPN "BPNL1234567890CD", validUntil "1112-11-11T11:11:11.111Z"
    And I fetch all policies

    Then the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-2222" and validUntil "2222-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890CD" should have a policy with policyId "integration-test-policy-1111" and validUntil "1112-11-11T11:11:11.111Z"
    And the BPN "BPNL1234567890AB" should have 0 policies having policyId starting with "integration-test-policy-"



  Scenario: Add policyId to given BPNs

    Given no policies with prefix "integration-test-policy-" exist
    Given a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"
    And   I fetch all policies
    And   the BPN "BPNL1234567890AB" should have the following policies:
      | integration-test-policy-1111 |
    And the BPN "BPNL1234567890CD" should have 0 policies having policyId starting with "integration-test-policy-"

    When I add policyId "integration-test-policy-1111" to given BPNs using validUntil "1112-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890CD |
    And I fetch all policies

    Then the BPNs should be associated with policies as follows:
      | BPN              | policyId                     |
      | BPNL1234567890AB | integration-test-policy-1111 |
      | BPNL1234567890CD | integration-test-policy-1111 |


  Scenario: Delete 3 policies
    Given no policies with prefix "integration-test-policy-" exist
    Given a policy with policyId "integration-test-policy-1111" is registered for BPN "BPNL1234567890AB" and validUntil "2222-11-11T11:11:11.111Z"
    And I add policyId "integration-test-policy-1111" to given BPNs using validUntil "1111-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890EF |
    And a policy with policyId "integration-test-policy-2222" is registered for BPN "BPNL1234567890AB" and validUntil "1111-11-11T11:11:11.111Z"
    And I add policyId "integration-test-policy-2222" to given BPNs using validUntil "1111-11-11T11:11:11.111Z":
      | BPNL1234567890AB |
      | BPNL1234567890CD |
    And   a policy with policyId "integration-test-policy-3333" is registered for BPN "BPNL1234567890CD" and validUntil "2222-11-11T11:11:11.111Z"
    And   a policy with policyId "integration-test-policy-4444" is registered for BPN "BPNL1234567890CD" and validUntil "2222-11-11T11:11:11.111Z"
    And I fetch all policies
    And the BPNs should be associated with policies as follows:
      | BPN              | policyId                     |
      | BPNL1234567890AB | integration-test-policy-1111 |
      | BPNL1234567890EF | integration-test-policy-1111 |
      | BPNL1234567890AB | integration-test-policy-2222 |
      | BPNL1234567890CD | integration-test-policy-2222 |
      | BPNL1234567890CD | integration-test-policy-3333 |
      | BPNL1234567890CD | integration-test-policy-4444 |

    When I delete the following policies:
      | integration-test-policy-2222 |
      | integration-test-policy-3333 |
      | integration-test-policy-4444 |
    And  I fetch all policies

    Then the BPN "BPNL1234567890CD" should have 0 policies having policyId starting with "integration-test-policy-"
    And  the BPNs should be associated with policies as follows:
      | BPN              | policyId                     |
      | BPNL1234567890AB | integration-test-policy-1111 |
      | BPNL1234567890EF | integration-test-policy-1111 |


