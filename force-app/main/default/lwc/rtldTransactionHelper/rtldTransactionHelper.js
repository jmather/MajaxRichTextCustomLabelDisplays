import getTransactionStatus from '@salesforce/apex/RTLD_AdminApi.getTransactionStatus'
import debug from 'c/rtldDebug';

/**
 * @typedef {Object} MAJAX__RTLD_TransactionStatus
 * @property {String} txnId
 * @property {Number} count
 * @property {Boolean} isComplete
 * @property {Boolean} isSuccessful
 * @property {Boolean} isDebugging
 */

/**
 *
 * @param {Promise<MAJAX__RTLD_TransactionStatus>} promise
 * @param {Number} maxCheckCount
 * @param {Boolean} enableDebugging
 * @returns {Promise<MAJAX__RTLD_TransactionStatus>}
 */

export default function RtldTransactionHelper(promise, maxCheckCount = 15, enableDebugging = false) {
    return promise.then(statusJson => {
        const status = JSON.parse(statusJson);
        const nextIteration = () => {
            const check = getTransactionStatus({ txnId: status.txnId, count: status.count, enableDebugging });
            return RtldTransactionHelper(check, maxCheckCount, enableDebugging);
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