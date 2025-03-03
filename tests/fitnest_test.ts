import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create a new workout",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const block = chain.mineBlock([
      Tx.contractCall('fitnest', 'create-workout', 
        [types.ascii("Full Body HIIT"), types.uint(30), types.uint(3)], 
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectUint(1);
    
    const response = chain.callReadOnlyFn(
      'fitnest',
      'get-workout',
      [types.uint(1)],
      deployer.address
    );
    
    const workout = response.result.expectOk().expectSome();
    assertEquals(workout.name, "Full Body HIIT");
    assertEquals(workout.duration, 30);
    assertEquals(workout.difficulty, 3);
  }
});

Clarinet.test({
  name: "Cannot create workout with invalid parameters",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const block = chain.mineBlock([
      Tx.contractCall('fitnest', 'create-workout',
        [types.ascii(""), types.uint(0), types.uint(6)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectErr().expectUint(103); // err-invalid-params
  }
});

[Previous test cases remain unchanged...]
