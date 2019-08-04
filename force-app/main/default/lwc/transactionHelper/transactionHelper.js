import getTransactionStatus from '@salesforce/apex/AdminAPIv2.getTransactionStatus'
import debug from 'c/debug';

/**
 * @typedef {Object} MAJAX__AsyncTransactionStatus
 * @property {String} txnId
 * @property {Number} count
 * @property {Boolean} isComplete
 * @property {Boolean} isSuccessful
 * @property {Boolean} isDebugging
 */

/**
 *
 * @param {Promise<MAJAX__AsyncTransactionStatus>} promise
 * @param {Number} maxCheckCount
 * @param {Boolean} enableDebugging
 * @returns {Promise<MAJAX__AsyncTransactionStatus>}
 */
export default function transactionHelper(promise, maxCheckCount = 15, enableDebugging = false) {
    return promise.then(statusJson => {
        const status = JSON.parse(statusJson);
        const nextIteration = () => {
            const check = getTransactionStatus({ txnId: status.txnId, count: status.count, enableDebugging });
            return transactionHelper(check, maxCheckCount, enableDebugging);
        };

        debug(enableDebugging, '[transactionHelper] status', status);

        if (status.isComplete === true) {
            return status;
        }

        if (status.count > maxCheckCount) {
            debug(enableDebugging, '[transactionHelper] bailing out...');
            throw new Error("Ran out of retries");
        }

        return new Promise((accept) => {
            setTimeout(accept, 500);
        }).then(nextIteration);
    });
}