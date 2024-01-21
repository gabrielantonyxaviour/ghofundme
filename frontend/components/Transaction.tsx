import React, { useState, useEffect } from 'react';

interface Transaction {
  id: number;
  description: string;
  amount: number;
}

const mockTransactions: Transaction[] = [
  { id: 1, description: 'Transaction 1', amount: 50 },
  { id: 2, description: 'Transaction 2', amount: -30 },
  { id: 1, description: 'Transaction 1', amount: 50 },
  { id: 2, description: 'Transaction 2', amount: -30 },  { id: 2, description: 'Transaction 2', amount: -30 },
  { id: 1, description: 'Transaction 1', amount: 50 },
  { id: 2, description: 'Transaction 2', amount: -30 },  { id: 2, description: 'Transaction 2', amount: -30 },


];

const TransactionList: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>(mockTransactions);

  useEffect(() => {
    // Fetch or set transactions as needed
  }, []);

  return (
    <div
      className="h-[355px] w-[340px] overflow-y-auto bg-gray-800 rounded-xl"
      style={{
        scrollbarWidth: 'thin',
        scrollbarColor: 'transparent transparent', // Firefox scrollbar color
        overflow: '-moz-scrollbars-none', // Hide Firefox scrollbar
      }}
    >
      <style>
        {`
          .custom-scrollbar::-webkit-scrollbar {
            width: 8px;
          }

          .custom-scrollbar::-webkit-scrollbar-thumb {
            background-color: transparent; /* Scrollbar thumb color */
            border-radius: 10px;
          }

          .custom-scrollbar::-webkit-scrollbar-track {
            background-color: #282c34; /* Scrollbar track color */
            border-radius: 10px;
          }
        `}
      </style>

      {transactions.map((transaction) => (
        <div key={transaction.id} className="transaction-item border rounded-xl p-4 text-xs">
          <p className="font-normal text-sm">Description: {transaction.description}</p>
          <p>Amount: {transaction.amount} GHO</p>
        </div>
      ))}
    </div>
  );
};

export default TransactionList;
