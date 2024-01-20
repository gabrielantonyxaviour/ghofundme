import React, { useState, useEffect } from 'react';

interface Transaction {
  id: number;
  description: string;
  amount: number;
}

const mockTransactions: Transaction[] = [
  { id: 1, description: 'Transaction 1', amount: 50 },
  { id: 2, description: 'Transaction 2', amount: -30 },  { id: 2, description: 'Transaction 2', amount: -30 },

];

const TransactionList: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>(mockTransactions);

  useEffect(() => {
    // Fetch or set transactions as needed
  }, []);

  return (
    <div className="custom-scrollbar max-h-96 overflow-y-auto scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-gray-100">
      {transactions.map((transaction) => (
        <div key={transaction.id} className="transaction-item border-b p-4">
          <p className="font-semibold">Description: {transaction.description}</p>
          <p>Amount: ${transaction.amount}</p>
        </div>
      ))}
    </div>
  );
};

export default TransactionList;
