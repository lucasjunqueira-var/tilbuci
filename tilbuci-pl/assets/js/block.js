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
    var InspectorControls = wp.editor.InspectorControls || wp.blockEditor.InspectorControls;
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
            wp.apiFetch({ path: '/tilbuci-wp/v1/movies' })
                .then(function (data) {
                    setMovies(data);
                    setIsLoading(false);
                })
                .catch(function (err) {
                    setError(err.message || __('Error loading movies', 'tilbuci-wp'));
                    setIsLoading(false);
                });
        }, []);

        // select options
        var options = [];
        if (movies && movies.length > 0) {
            options.push({ label: __('Select a TilBuci movie', 'tilbuci-wp'), value: '' });
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
                label: __('TilBuci Movie', 'tilbuci-wp')
            }, createElement(Spinner, null));
        }

        // error message
        if (error) {
            return createElement(Placeholder, {
                icon: 'video-alt',
                label: __('TilBuci Movie', 'tilbuci-wp')
            }, __('Error loading movies:', 'tilbuci-wp') + ' ' + error);
        }

        // no movies available
        if (!movies || movies.length === 0) {
            return createElement(Placeholder, {
                icon: 'video-alt',
                label: __('TilBuci Movie', 'tilbuci-wp')
            }, __('No movies found in the database.', 'tilbuci-wp'));
        }

        // cntrols render
        return [
            createElement(InspectorControls, { key: 'inspector' },
                createElement(PanelBody, { title: __('Display Settings', 'tilbuci-wp'), initialOpen: true },
                    createElement(ToggleControl, {
                        label: __('Full Screen', 'tilbuci-wp'),
                        checked: attributes.fullScreen,
                        onChange: function (value) {
                            setAttributes({ fullScreen: value });
                        },
                        help: __('If enabled, the content will be displayed covering the entire page area.', 'tilbuci-wp')
                    }),
                    !attributes.fullScreen && createElement(TextControl, {
                        label: __('Height (%)', 'tilbuci-wp'),
                        type: 'number',
                        value: attributes.height,
                        onChange: function (value) {
                            var num = parseInt(value, 10);
                            if (!isNaN(num) && num >= 0 && num <= 100) {
                                setAttributes({ height: num });
                            }
                        },
                        help: __('Percentage of height relative to content display width - the default is 56%, ideal for 16x9 aspect ratio content.', 'tilbuci-wp')
                    })
                )
            ),
            createElement('div', { className: 'tilbuci-block-editor', key: 'editor' },
                createElement(SelectControl, {
                    label: __('Select a TilBuci movie', 'tilbuci-wp'),
                    value: attributes.movieId,
                    options: options,
                    onChange: function (value) {
                        setAttributes({ movieId: value });
                    }
                })
            )
        ];
    };

    // block registering
    registerBlockType('tilbuci-wp/tilbuci-block', {
        title: __('TilBuci Movie', 'tilbuci-wp'),
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
            }
        },
        edit: Edit,
        save: function () {
            return null;
        }
    });

    // REST for movies
    wp.apiFetch.use(function (options, next) {
        if (options.path && options.path.indexOf('/tilbuci-wp/v1/movies') === 0) {
            return next(options);
        }
        return next(options);
    });

})(window.wp);