(function (wp) {
    var __ = wp.i18n.__;
    var createElement = wp.element.createElement;
    var registerBlockType = wp.blocks.registerBlockType;
    var SelectControl = wp.components.SelectControl;
    var ToggleControl = wp.components.ToggleControl;
    var TextControl = wp.components.TextControl;
    var Placeholder = wp.components.Placeholder;
    var Spinner = wp.components.Spinner;
    var PanelBody = wp.components.PanelBody;
    var InspectorControls = wp.blockEditor ? wp.blockEditor.InspectorControls : wp.editor.InspectorControls;
    var withSelect = wp.data.withSelect;
    var useSelect = wp.data.useSelect;

    // Block editor component
    var Edit = function (props) {
        var attributes = props.attributes;
        var setAttributes = props.setAttributes;
        
        // hooks
        var useState = wp.element.useState;
        var useEffect = wp.element.useEffect;
        
        // movie loading
        var _useState = useState([]);
        var movies = _useState[0];
        var setMovies = _useState[1];
        
        var _useState2 = useState(true);
        var isLoading = _useState2[0];
        var setIsLoading = _useState2[1];
        
        var _useState3 = useState(null);
        var error = _useState3[0];
        var setError = _useState3[1];

        // looking for available movies
        useEffect(function () {
            wp.apiFetch({ path: '/tilbuci-pl/v1/movies' })
                .then(function (data) {
                    setMovies(data);
                    setIsLoading(false);
                })
                .catch(function (err) {
                    setError(err.message || __('Error loading movies', 'tilbuci-pl'));
                    setIsLoading(false);
                });
        }, []);

        // select options
        var options = [];
        if (movies && movies.length > 0) {
            options.push({ label: __('Select a TilBuci movie', 'tilbuci-pl'), value: '' });
            movies.forEach(function (movie) {
                options.push({
                    label: movie.mv_title,
                    value: movie.mv_id
                });
            });
        }

        // spinner
        if (isLoading) {
            return createElement(Placeholder, {
                icon: 'video-alt',
                label: __('TilBuci Movie', 'tilbuci-pl')
            }, createElement(Spinner, null));
        }

        // error message
        if (error) {
            return createElement(Placeholder, {
                icon: 'video-alt',
                label: __('TilBuci Movie', 'tilbuci-pl')
            }, __('Error loading movies:', 'tilbuci-pl') + ' ' + error);
        }

        // no movies available
        if (!movies || movies.length === 0) {
            return createElement(Placeholder, {
                icon: 'video-alt',
                label: __('TilBuci Movie', 'tilbuci-pl')
            }, __('No movies found in the database.', 'tilbuci-pl'));
        }

        // Helper to generate custom variable controls
        var customVariables = [];
        for (var i = 1; i <= 5; i++) {
            (function (idx) {
                customVariables.push(
                    createElement('div', { key: 'custom-var-' + idx, style: { marginBottom: '15px' } },
                        createElement(TextControl, {
                            label: __('Variable', 'tilbuci-pl') + ' ' + idx + ' name',
                            value: attributes['customVar' + idx] || '',
                            __next40pxDefaultSize: true,
                            __nextHasNoMarginBottom: true,
                            onChange: function (value) {
                                var newAttrs = {};
                                newAttrs['customVar' + idx] = value;
                                setAttributes(newAttrs);
                            }
                        }),
                        createElement(TextControl, {
                            label: __('Variable', 'tilbuci-pl') + ' ' + idx + ' value',
                            value: attributes['customVal' + idx] || '',
                            __next40pxDefaultSize: true,
                            __nextHasNoMarginBottom: true,
                            onChange: function (value) {
                                var newAttrs = {};
                                newAttrs['customVal' + idx] = value;
                                setAttributes(newAttrs);
                            }
                        })
                    )
                );
            })(i);
        }

        // render
        return createElement('div', {},
            createElement(InspectorControls, { key: 'inspector' },
                createElement(PanelBody, { title: __('Display Settings', 'tilbuci-pl'), initialOpen: true },
                    createElement(ToggleControl, {
                        label: __('Full Screen', 'tilbuci-pl'),
                        checked: attributes.fullScreen,
                        __nextHasNoMarginBottom: true,
                        onChange: function (value) {
                            setAttributes({ fullScreen: value });
                        },
                        help: __('If enabled, the content will be displayed covering the entire page area.', 'tilbuci-pl')
                    }),
                    !attributes.fullScreen && createElement(TextControl, {
                        label: __('Height (%)', 'tilbuci-pl'),
                        type: 'number',
                        value: attributes.height,
                        __next40pxDefaultSize: true,
                        __nextHasNoMarginBottom: true,
                        onChange: function (value) {
                            var num = parseInt(value, 10);
                            if (!isNaN(num) && num >= 0 && num <= 100) {
                                setAttributes({ height: num });
                            }
                        },
                        help: __('Percentage of height relative to content display width - the default is 56%, ideal for 16x9 aspect ratio content.', 'tilbuci-pl')
                    })
                ),
                createElement(PanelBody, { title: __('Custom Variables', 'tilbuci-pl'), initialOpen: false },
                    createElement('p', { style: { marginTop: 0 } },
                        __('You can set up to five string variables to be sent to the loaded TilBuci movie.', 'tilbuci-pl')
                    ),
                    customVariables
                )
            ),
            createElement(SelectControl, {
                label: __('Select a TilBuci movie', 'tilbuci-pl'),
                value: attributes.movieId,
                options: options,
                __next40pxDefaultSize: true,
                __nextHasNoMarginBottom: true,
                onChange: function (value) {
                    setAttributes({ movieId: value });
                }
            })
        );
    };

    // block registering
    registerBlockType('tilbuci-pl/tilbuci-block', {
        title: __('TilBuci Movie', 'tilbuci-pl'),
        icon: 'video-alt', // WordPress SVG icon "captureVideo"
        category: 'embed',
        attributes: {
            movieId: {
                type: 'string',
                default: ''
            },
            fullScreen: {
                type: 'boolean',
                default: false
            },
            height: {
                type: 'number',
                default: 56
            },
            customVar1: {
                type: 'string',
                default: ''
            },
            customVal1: {
                type: 'string',
                default: ''
            },
            customVar2: {
                type: 'string',
                default: ''
            },
            customVal2: {
                type: 'string',
                default: ''
            },
            customVar3: {
                type: 'string',
                default: ''
            },
            customVal3: {
                type: 'string',
                default: ''
            },
            customVar4: {
                type: 'string',
                default: ''
            },
            customVal4: {
                type: 'string',
                default: ''
            },
            customVar5: {
                type: 'string',
                default: ''
            },
            customVal5: {
                type: 'string',
                default: ''
            }
        },
        edit: Edit,
        save: function () {
            return null;
        }
    });

    // REST for movies
    wp.apiFetch.use(function (options, next) {
        if (options.path && options.path.indexOf('/tilbuci-pl/v1/movies') === 0) {
            return next(options);
        }
        return next(options);
    });

})(window.wp);