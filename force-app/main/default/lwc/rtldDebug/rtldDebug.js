/**
 * Created by jmather on 2019-07-30.
 */

/**
 * @param {Boolean} enableDebugging
 * @param {...*} var_args
 */
export default function RtldDebug(enableDebugging, var_args) {
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
RtldDebug.event = (enableDebugging, prefix, eventObj) => {
    RtldDebug(enableDebugging, '[' + prefix + '] event', eventObj);
    RtldDebug(enableDebugging, '[' + prefix + '] event detail', eventObj.detail);
    if (eventObj.type === 'click') {
        RtldDebug(enableDebugging, '[' + prefix + '] event target', eventObj.target);
        RtldDebug(enableDebugging, '[' + prefix + '] event srcElement', eventObj.srcElement);
    }
};