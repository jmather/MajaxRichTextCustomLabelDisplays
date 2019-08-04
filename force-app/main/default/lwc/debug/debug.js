/**
 * Created by jmather on 2019-07-30.
 */

/**
 * @param {Boolean} enableDebugging
 * @param {...*} var_args
 */
export default function debug(enableDebugging, var_args) {
    if (enableDebugging === false) {
        return;
    }

    const args = [];
    for (let i = 1; i < arguments.length; i++) {
        // console.log('type of', typeof(arguments[i]), arguments[i]);
        let arg = arguments[i];

        try {
            arg = JSON.parse(JSON.stringify(arg));
        } catch (e) {
            // nope... lol.
        }

        args.push(arg);
    }

    console.log.apply(console, args);
}

/**
 * @param {Boolean} enableDebugging
 * @param {String} prefix
 * @param {Event} eventObj
 */
debug.event = (enableDebugging, prefix, eventObj) => {
    debug(enableDebugging, '[' + prefix + '] event', eventObj);
    debug(enableDebugging, '[' + prefix + '] event detail', eventObj.detail);
    if (eventObj.type === 'click') {
        debug(enableDebugging, '[' + prefix + '] event target', eventObj.target);
        debug(enableDebugging, '[' + prefix + '] event srcElement', eventObj.srcElement);
    }
};